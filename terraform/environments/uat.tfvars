# UAT environment Terraform variables
aws_region   = "us-east-1"
project_name = "react-js-application"
environment  = "uat"

vpc_cidr                 = "10.50.0.0/16"
az_count                 = 2
public_subnet_cidrs      = ['10.50.1.0/24', '10.50.2.0/24']
private_app_subnet_cidrs = ['10.50.11.0/24', '10.50.12.0/24']
private_db_subnet_cidrs  = ['10.50.21.0/24', '10.50.22.0/24']

allowed_http_cidr = "0.0.0.0/0"
allowed_ssh_cidr  = "YOUR_PUBLIC_IP/32"
key_name          = null

instance_type        = "t3.micro"
image_tag            = "latest"
db_name              = "tododb"
db_username          = "todo_admin"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20

# Do not store db_password in this file.
# GitHub Actions passes db_password from the DB_PASSWORD secret.

tags = {
  Project     = "react-js-application"
  Environment = "uat"
  ManagedBy   = "Terraform"
}
