aws_region   = "us-east-1"
project_name = "react-js-application"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"
az_count = 2

public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

allowed_http_cidr = "0.0.0.0/0"
allowed_ssh_cidr  = "0.0.0.0/0"

key_name = ""

frontend_instance_type = "t2.micro"
backend_instance_type  = "t2.micro"

frontend_image_tag = "latest"
backend_image_tag  = "latest"

db_name              = "todoapp"
db_username          = "todo_admin"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20

tags = {
  Owner       = "Olalekan"
  Application = "react-js-application"
}
