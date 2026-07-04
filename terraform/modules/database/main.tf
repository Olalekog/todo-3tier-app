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

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })

  frontend_image_uri = "${module.ecr.frontend_repository_url}:${var.image_tag}"
  backend_image_uri  = "${module.ecr.backend_repository_url}:${var.image_tag}"
}

module "network" {
  source = "./modules/network"

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  azs                      = local.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  tags                     = local.common_tags
}

module "security_groups" {
  source = "./modules/security-groups"

  project_name                = var.project_name
  environment                 = var.environment
  vpc_id                      = module.network.vpc_id
  allowed_http_cidr           = var.allowed_http_cidr
  allowed_ssh_cidr            = var.allowed_ssh_cidr
  backend_allowed_cidr_blocks = var.private_app_subnet_cidrs
  tags                        = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

module "database" {
  source = "./modules/database"

  project_name          = var.project_name
  environment           = var.environment
  private_db_subnet_ids = module.network.private_db_subnet_ids
  db_security_group_id  = module.security_groups.database_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  tags                  = local.common_tags
}

# Backend EC2 workload: uses the same reusable compute module as frontend,
# but has its own module block, subnet, security group, image, user data, and instance type.
module "backend_compute" {
  source = "./modules/compute"

  project_name                = var.project_name
  environment                 = var.environment
  workload_name               = "backend"
  aws_region                  = var.aws_region
  ami_id                      = data.aws_ami.ubuntu.id
  instance_type               = var.backend_instance_type
  key_name                    = var.key_name == "" ? null : var.key_name
  subnet_id                   = module.network.private_app_subnet_ids[0]
  security_group_id           = module.security_groups.backend_security_group_id
  associate_public_ip_address = false
  image_uri                   = local.backend_image_uri
  user_data_template_path     = "${path.module}/templates/user_data_backend.sh.tftpl"
  db_host                     = module.database.db_address
  db_name                     = var.db_name
  db_username                 = var.db_username
  db_password                 = var.db_password
  tags                        = local.common_tags
}

# Frontend EC2 workload: uses the same reusable compute module as backend,
# but has a separate module block so frontend can change independently.
module "frontend_compute" {
  source = "./modules/compute"

  project_name                = var.project_name
  environment                 = var.environment
  workload_name               = "frontend"
  aws_region                  = var.aws_region
  ami_id                      = data.aws_ami.ubuntu.id
  instance_type               = var.frontend_instance_type
  key_name                    = var.key_name == "" ? null : var.key_name
  subnet_id                   = module.network.public_subnet_ids[0]
  security_group_id           = module.security_groups.frontend_security_group_id
  associate_public_ip_address = true
  image_uri                   = local.frontend_image_uri
  user_data_template_path     = "${path.module}/templates/user_data_frontend.sh.tftpl"
  db_host                     = ""
  db_name                     = ""
  db_username                 = ""
  db_password                 = ""
  tags                        = local.common_tags
}
