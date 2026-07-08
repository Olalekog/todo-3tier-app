data "aws_subnet" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0
  id    = var.sonarqube_subnet_id
}

check "sonarqube_subnet_in_vpc" {
  assert {
    condition     = !var.enable_sonarqube || try(data.aws_subnet.sonarqube[0].vpc_id, "") == var.vpc_id
    error_message = "SonarQube subnet must belong to the same VPC as the app infrastructure."
  }
}

check "sonarqube_subnet_is_public" {
  assert {
    condition     = !var.enable_sonarqube || try(data.aws_subnet.sonarqube[0].map_public_ip_on_launch, false)
    error_message = "SonarQube must be deployed in a public subnet with auto-assign public IP enabled."
  }
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = var.vpc_id
  allowed_ssh_cidr       = var.allowed_ssh_cidr
  sonarqube_allowed_cidr = var.allowed_ssh_cidr
  enable_frontend        = false
  enable_backend         = false
  enable_database        = false
  enable_sonarqube       = var.enable_sonarqube
  tags                   = var.tags
}

module "sonarqube_compute" {
  count  = var.enable_sonarqube ? 1 : 0
  source = "../../modules/compute"

  project_name                = var.project_name
  environment                 = var.environment
  workload_name               = "sonarqube"
  aws_region                  = var.aws_region
  ami_id                      = var.ami_id
  instance_type               = var.sonarqube_instance_type
  key_name                    = var.key_name == "" ? null : var.key_name
  subnet_id                   = var.sonarqube_subnet_id
  security_group_id           = module.security_groups.sonarqube_security_group_id
  associate_public_ip_address = true

  image_uri               = ""
  ecr_repository_arns     = []
  user_data_template_path = var.user_data_template_path
  db_host                 = ""
  db_name                 = ""
  db_username             = ""
  db_password             = ""
  backend_private_ip      = ""

  user_data_template_vars = {
    sonarqube_version = var.sonarqube_version
  }

  tags = merge(var.tags, {
    Tier = "tools"
  })
}