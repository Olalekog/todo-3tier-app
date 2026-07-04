# This module creates exactly two separate single EC2 instances:
# - aws_instance.frontend in a public subnet, running the React Docker image
# - aws_instance.backend in a private subnet, running the FastAPI Docker image

resource "aws_iam_role" "ec2_ecr_pull" {
  name = "${var.project_name}-${var.environment}-ec2-ecr-pull-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ec2-ecr-pull-role"
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_pull.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_ecr_pull" {
  name = "${var.project_name}-${var.environment}-ec2-ecr-pull-profile"
  role = aws_iam_role.ec2_ecr_pull.name

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ec2-ecr-pull-profile"
  })
}

resource "aws_instance" "backend" {
  ami                         = var.ami_id
  instance_type               = var.backend_instance_type
  subnet_id                   = var.backend_subnet_id
  vpc_security_group_ids      = [var.backend_security_group_id]
  associate_public_ip_address = false
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_ecr_pull.name

  user_data_replace_on_change = true

  user_data = templatefile(var.user_data_backend_path, {
    aws_region        = var.aws_region
    backend_image_uri = var.backend_image_uri
    db_host           = var.db_host
    db_name           = var.db_name
    db_username       = var.db_username
    db_password       = var.db_password
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-backend"
    Tier = "backend"
  })
}

resource "aws_instance" "frontend" {
  ami                         = var.ami_id
  instance_type               = var.frontend_instance_type
  subnet_id                   = var.frontend_subnet_id
  vpc_security_group_ids      = [var.frontend_security_group_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_ecr_pull.name

  user_data_replace_on_change = true

  user_data = templatefile(var.user_data_frontend_path, {
    aws_region         = var.aws_region
    frontend_image_uri = var.frontend_image_uri
    backend_private_ip = aws_instance.backend.private_ip
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-frontend"
    Tier = "frontend"
  })

  depends_on = [aws_instance.backend]
}