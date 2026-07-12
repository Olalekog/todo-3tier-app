data "aws_subnet" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0
  id    = var.sonarqube_subnet_id
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

data "aws_instances" "existing_sonarqube" {
  count = var.enable_sonarqube ? 1 : 0

  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-sonarqube"]
  }

  filter {
    name   = "instance-state-name"
    values = ["pending", "running", "stopping", "stopped"]
  }
}

data "aws_instance" "existing_sonarqube" {
  count       = var.enable_sonarqube && length(data.aws_instances.existing_sonarqube[0].ids) > 0 ? 1 : 0
  instance_id = sort(data.aws_instances.existing_sonarqube[0].ids)[0]
}

locals {
  sonarqube_ami_id = length(data.aws_instance.existing_sonarqube) > 0 ? data.aws_instance.existing_sonarqube[0].ami : (var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id)
}

check "sonarqube_subnet_in_vpc" {
  assert {
    condition     = !var.enable_sonarqube || try(data.aws_subnet.sonarqube[0].vpc_id, "") == var.vpc_id
    error_message = "Security tools subnet must belong to the configured VPC."
  }
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name                      = var.project_name
  environment                       = var.environment
  vpc_id                            = var.vpc_id
  allowed_http_cidr                 = var.allowed_http_cidr
  allowed_ssh_cidr                  = var.allowed_ssh_cidr
  sonarqube_allowed_cidr            = var.allowed_ssh_cidr
  tcp_protocol                      = var.tcp_protocol
  frontend_http_port                = var.frontend_http_port
  backend_api_port                  = var.backend_api_port
  database_port                     = var.database_port
  outbound_http_port                = var.outbound_http_port
  outbound_https_port               = var.outbound_https_port
  app_outbound_cidr_ipv4            = var.app_outbound_cidr_ipv4
  sonarqube_port                    = var.sonarqube_port
  grafana_port                      = var.grafana_port
  prometheus_port                   = var.prometheus_port
  trivy_port                        = var.trivy_port
  ssh_port                          = var.ssh_port
  security_tools_outbound_cidr_ipv4 = var.security_tools_outbound_cidr_ipv4
  enable_frontend                   = false
  enable_backend                    = false
  enable_database                   = false
  enable_sonarqube                  = var.enable_sonarqube
  tags                              = var.tags
}

module "sonarqube_compute" {
  count  = var.enable_sonarqube ? 1 : 0
  source = "../../modules/compute"

  project_name                = var.project_name
  environment                 = var.environment
  workload_name               = "sonarqube"
  aws_region                  = var.aws_region
  ami_id                      = local.sonarqube_ami_id
  instance_type               = var.sonarqube_instance_type
  root_volume_size            = var.sonarqube_root_volume_size
  key_name                    = var.key_name == "" ? null : var.key_name
  subnet_id                   = var.sonarqube_subnet_id
  security_group_id           = module.security_groups.sonarqube_security_group_id
  associate_public_ip_address = true
  disable_api_termination     = false
  user_data_replace_on_change = false

  image_uri               = ""
  ecr_repository_arns     = []
  user_data_template_path = var.user_data_template_path
  db_host                 = ""
  db_name                 = ""
  db_username             = ""
  db_password             = ""
  backend_private_ip      = ""

  user_data_template_vars = {
    sonarqube_image  = var.sonarqube_image
    trivy_image      = var.trivy_image
    checkov_image    = var.checkov_image
    prometheus_image = var.prometheus_image
    grafana_image    = var.grafana_image
  }

  tags = merge(var.tags, {
    Tier = "tools"
  })
}
