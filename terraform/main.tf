data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_instances" "existing_backend" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-backend"]
  }

  filter {
    name   = "instance-state-name"
    values = ["pending", "running", "stopping", "stopped"]
  }
}

data "aws_instance" "existing_backend" {
  count       = length(data.aws_instances.existing_backend.ids) > 0 ? 1 : 0
  instance_id = sort(data.aws_instances.existing_backend.ids)[0]
}

data "aws_instances" "existing_frontend" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-frontend"]
  }

  filter {
    name   = "instance-state-name"
    values = ["pending", "running", "stopping", "stopped"]
  }
}

data "aws_instance" "existing_frontend" {
  count       = length(data.aws_instances.existing_frontend.ids) > 0 ? 1 : 0
  instance_id = sort(data.aws_instances.existing_frontend.ids)[0]
}

locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"

  frontend_image_uri = "${module.ecr.frontend_repository_url}:${var.frontend_image_tag}"
  backend_image_uri  = "${module.ecr.backend_repository_url}:${var.backend_image_tag}"

  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  backend_ami_id  = length(data.aws_instance.existing_backend) > 0 ? data.aws_instance.existing_backend[0].ami : data.aws_ami.ubuntu.id
  frontend_ami_id = length(data.aws_instance.existing_frontend) > 0 ? data.aws_instance.existing_frontend[0].ami : data.aws_ami.ubuntu.id

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

module "network" {
  source = "./modules/network"

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = local.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  tags                     = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

module "security_groups" {
  source = "./modules/security-groups"

  project_name                = var.project_name
  environment                 = var.environment
  vpc_id                      = module.network.vpc_id
  allowed_http_cidr           = var.allowed_http_cidr
  allowed_ssh_cidr            = var.allowed_ssh_cidr
  backend_allowed_cidr_blocks = length(var.backend_allowed_cidr_blocks) > 0 ? var.backend_allowed_cidr_blocks : var.private_app_subnet_cidrs
  tags                        = local.common_tags
}

module "database" {
  source = "./modules/database"

  project_name              = var.project_name
  environment               = var.environment
  name_suffix               = "app"
  vpc_id                    = module.network.vpc_id
  private_db_subnet_ids     = module.network.private_db_subnet_ids
  private_db_subnet_vpc_ids = module.network.private_db_subnet_vpc_ids
  db_security_group_id      = module.security_groups.database_security_group_id
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  db_instance_class         = var.db_instance_class
  allocated_storage         = var.db_allocated_storage
  deletion_protection       = var.db_deletion_protection
  tags                      = local.common_tags
}

module "backend_compute" {
  source = "./modules/compute"

  project_name                = var.project_name
  environment                 = var.environment
  workload_name               = "backend"
  aws_region                  = var.aws_region
  ami_id                      = local.backend_ami_id
  instance_type               = var.backend_instance_type
  key_name                    = var.key_name == "" ? null : var.key_name
  subnet_id                   = module.network.private_app_subnet_ids[0]
  security_group_id           = module.security_groups.backend_security_group_id
  associate_public_ip_address = false
  user_data_replace_on_change = false

  image_uri               = local.backend_image_uri
  user_data_template_path = "${path.module}/templates/user_data_backend.sh.tftpl"
  ecr_repository_arns     = [module.ecr.backend_repository_arn]

  db_host     = module.database.db_address
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  tags = local.common_tags
}

module "frontend_compute" {
  source = "./modules/compute"

  project_name                = var.project_name
  environment                 = var.environment
  workload_name               = "frontend"
  aws_region                  = var.aws_region
  ami_id                      = local.frontend_ami_id
  instance_type               = var.frontend_instance_type
  key_name                    = var.key_name == "" ? null : var.key_name
  subnet_id                   = module.network.public_subnet_ids[0]
  security_group_id           = module.security_groups.frontend_security_group_id
  associate_public_ip_address = true
  user_data_replace_on_change = false

  image_uri               = local.frontend_image_uri
  user_data_template_path = "${path.module}/templates/user_data_frontend.sh.tftpl"
  ecr_repository_arns     = [module.ecr.frontend_repository_arn]

  backend_private_ip = module.backend_compute.private_ip

  db_host     = ""
  db_name     = ""
  db_username = ""
  db_password = ""

  tags = local.common_tags
}