# PROD environment Terraform variables
# Project: react-js-application

aws_region   = "us-east-1"
project_name = "react-js-application"
environment  = "prod"

# Network
vpc_cidr                 = "10.60.0.0/16"
az_count                 = 2
public_subnet_cidrs      = ["10.60.1.0/24", "10.60.2.0/24"]
private_app_subnet_cidrs = ["10.60.11.0/24", "10.60.12.0/24"]
private_db_subnet_cidrs  = ["10.60.21.0/24", "10.60.22.0/24"]

# Access
allowed_http_cidr = "0.0.0.0/0"
allowed_ssh_cidr  = "0.0.0.0/0" # Recommended: replace with your public IP or office/VPN CIDR.
key_name          = null

# Compute - separate frontend and backend workload sizing
frontend_instance_type = "t3.small"
backend_instance_type  = "t3.medium"

# Docker image tag is usually overridden by GitHub Actions using the promoted image tag.
image_tag = "latest"

# Database
# Do not store db_password in this file. GitHub Actions passes db_password from the DB_PASSWORD secret.
db_name              = "tododb"
db_username          = "todo_admin"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 30

# Tags
tags = {
  Project     = "react-js-application"
  Environment = "prod"
  ManagedBy   = "Terraform"
}
