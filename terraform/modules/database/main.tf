data "aws_subnet" "private_db" {
  for_each = toset(var.private_db_subnet_ids)
  id       = each.value
}

data "aws_security_group" "database" {
  id = var.db_security_group_id
}

locals {
  name_prefix = var.name_suffix == "" ? "${var.project_name}-${var.environment}" : "${var.project_name}-${var.environment}-${var.name_suffix}"
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  lifecycle {
    precondition {
      condition     = alltrue([for subnet in data.aws_subnet.private_db : subnet.vpc_id == var.vpc_id])
      error_message = "All database subnets must belong to the same VPC as the app infrastructure."
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-db-subnet-group"
    Tier = "database"
  })
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${local.name_prefix}-rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "this" {
  identifier             = "${local.name_prefix}-mysql"
  engine                 = "mysql"
  engine_version         = var.engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = "gp3"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = 3306
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]

  publicly_accessible                 = false
  multi_az                            = var.multi_az
  backup_retention_period             = var.backup_retention_period
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  monitoring_interval                 = 60
  monitoring_role_arn                 = aws_iam_role.rds_enhanced_monitoring.arn
  auto_minor_version_upgrade          = true
  iam_database_authentication_enabled = true
  copy_tags_to_snapshot               = true
  enabled_cloudwatch_logs_exports     = ["error", "general", "slowquery"]

  storage_encrypted = true

  lifecycle {
    precondition {
      condition     = data.aws_security_group.database.vpc_id == var.vpc_id
      error_message = "The database security group must belong to the same VPC as the app infrastructure."
    }

    # Avoid repeated no-op modify cycles caused by AWS-managed patching or
    # externally-rotated credentials when these are not intentional infra changes.
    ignore_changes = [
      engine_version,
      password,
    ]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-mysql"
    Tier = "database"
  })
}
