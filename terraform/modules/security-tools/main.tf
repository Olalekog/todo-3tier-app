module "deploy" {
  source = "./deploy"

  project_name                = var.project_name
  environment                 = var.environment
  vpc_id                      = var.vpc_id
  allowed_http_cidr           = var.allowed_http_cidr
  allowed_ssh_cidr            = var.allowed_ssh_cidr
  backend_allowed_cidr_blocks = var.backend_allowed_cidr_blocks
  tags                        = var.tags
}

module "integration" {
  source = "./integration"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = var.vpc_id
  public_subnet_id        = var.public_subnet_id
  ami_id                  = var.ami_id
  allowed_ssh_cidr        = var.allowed_ssh_cidr
  key_name                = var.key_name
  enable_sonarqube        = var.enable_sonarqube
  sonarqube_instance_type = var.sonarqube_instance_type
  sonarqube_version       = var.sonarqube_version
  user_data_template_path = var.sonarqube_user_data_template_path
  tags                    = var.tags
}
