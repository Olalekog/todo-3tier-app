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

resource "aws_iam_role" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0
  name  = "${var.project_name}-${var.environment}-sonarqube-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sonarqube_ssm" {
  count      = var.enable_sonarqube ? 1 : 0
  role       = aws_iam_role.sonarqube[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0
  name  = "${var.project_name}-${var.environment}-sonarqube-profile"
  role  = aws_iam_role.sonarqube[0].name
}

resource "aws_instance" "sonarqube" {
  count                       = var.enable_sonarqube ? 1 : 0
  ami                         = var.ami_id
  instance_type               = var.sonarqube_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.sonarqube[0].id]
  associate_public_ip_address = true
  key_name                    = var.key_name == "" ? null : var.key_name
  iam_instance_profile        = aws_iam_instance_profile.sonarqube[0].name

  user_data = templatefile(var.user_data_template_path, {
    sonarqube_version = var.sonarqube_version
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sonarqube"
    Tier = "tools"
  })
}
