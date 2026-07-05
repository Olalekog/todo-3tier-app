resource "aws_iam_role" "ec2_ecr_pull" {
  name = "${var.project_name}-${var.environment}-${var.workload_name}-ec2-ecr-pull-role"

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
    Name = "${var.project_name}-${var.environment}-${var.workload_name}-ec2-ecr-pull-role"
    Tier = var.workload_name
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_pull.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_ecr_pull.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-${var.environment}-${var.workload_name}-instance-profile"
  role = aws_iam_role.ec2_ecr_pull.name

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.workload_name}-instance-profile"
    Tier = var.workload_name
  })
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = aws_iam_instance_profile.this.name

  user_data_replace_on_change = false

  user_data = templatefile(var.user_data_template_path, {
    project_name       = var.project_name
    environment        = var.environment
    workload           = var.workload_name
    aws_region         = var.aws_region
    image_uri          = var.image_uri
    frontend_image_uri = var.image_uri
    backend_image_uri  = var.image_uri
    backend_private_ip = var.backend_private_ip
    db_host            = var.db_host
    db_name            = var.db_name
    db_username        = var.db_username
    db_password        = var.db_password
  })

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.workload_name}"
    Tier = var.workload_name
  })
}
