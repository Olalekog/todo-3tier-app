locals {
  sonarqube_allowed_cidr = var.sonarqube_allowed_cidr != "" ? var.sonarqube_allowed_cidr : var.allowed_ssh_cidr
}

resource "aws_security_group" "frontend" {
  count = var.enable_frontend ? 1 : 0
  #checkov:skip=CKV_AWS_260:Single-instance frontend is intentionally internet-facing on HTTP.
  #checkov:skip=CKV_AWS_382:Frontend instance requires outbound internet access for runtime dependencies.
  #checkov:skip=CKV2_AWS_5:Attachment is defined in root compute module.
  name        = "${var.project_name}-${var.environment}-frontend-sg"
  description = "Frontend security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP to frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_http_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-frontend-sg"
    Tier = "frontend"
  })
}

resource "aws_security_group" "backend" {
  count = var.enable_backend ? 1 : 0
  #checkov:skip=CKV_AWS_382:Backend instance requires outbound internet access via NAT for updates and image pulls.
  #checkov:skip=CKV2_AWS_5:Attachment is defined in root compute module.
  name        = "${var.project_name}-${var.environment}-backend-sg"
  description = "Backend security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow frontend to backend API"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend[0].id]
  }

  dynamic "ingress" {
    for_each = var.backend_allowed_cidr_blocks
    content {
      description = "Allow backend API from allowed private CIDR ${ingress.value}"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-backend-sg"
    Tier = "backend"
  })
}

resource "aws_security_group" "database" {
  count = var.enable_database ? 1 : 0
  #checkov:skip=CKV_AWS_382:RDS managed service controls outbound traffic; explicit egress lock-down is deferred.
  #checkov:skip=CKV2_AWS_5:Attachment is defined in root database module.
  name        = "${var.project_name}-${var.environment}-database-sg"
  description = "Database security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL from backend security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend[0].id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-database-sg"
    Tier = "database"
  })
}

resource "aws_security_group" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0
  #checkov:skip=CKV2_AWS_5:Attachment is defined in root compute module.
  name        = "${var.project_name}-${var.environment}-sonarqube-sg"
  description = "SonarQube security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "SonarQube web UI from allowed CIDR"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [local.sonarqube_allowed_cidr]
  }

  ingress {
    description = "Grafana web UI from allowed CIDR"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [local.sonarqube_allowed_cidr]
  }

  ingress {
    description = "Prometheus web UI from allowed CIDR"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [local.sonarqube_allowed_cidr]
  }

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.sonarqube_allowed_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
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
