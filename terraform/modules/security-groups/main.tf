resource "aws_security_group" "frontend" {
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
    security_groups = [aws_security_group.frontend.id]
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
    security_groups = [aws_security_group.backend.id]
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
