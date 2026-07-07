resource "aws_security_group" "sonarqube" {
  count       = var.enable_sonarqube ? 1 : 0
  name        = "${var.project_name}-${var.environment}-sonarqube-sg"
  description = "SonarQube server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SonarQube web UI from admin CIDR"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "SSH from admin CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sonarqube-sg"
    Tier = "tools"
  })
}

module "sonarqube_compute" {
  count  = var.enable_sonarqube ? 1 : 0
  source = "../../compute"

  project_name                = var.project_name
  environment                 = var.environment
  workload_name               = "sonarqube"
  aws_region                  = var.aws_region
  ami_id                      = var.ami_id
  instance_type               = var.sonarqube_instance_type
  key_name                    = var.key_name == "" ? null : var.key_name
  subnet_id                   = var.sonarqube_subnet_id
  security_group_id           = aws_security_group.sonarqube[0].id
  associate_public_ip_address = false

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