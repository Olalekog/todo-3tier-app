environment = "uat"

vpc_cidr = "10.30.0.0/16"

public_subnet_cidrs = [
  "10.30.1.0/24",
  "10.30.2.0/24"
]

private_app_subnet_cidrs = [
  "10.30.11.0/24",
  "10.30.12.0/24"
]

private_db_subnet_cidrs = [
  "10.30.21.0/24",
  "10.30.22.0/24"
]

frontend_instance_type = "t3.micro"
backend_instance_type  = "t3.micro"

db_instance_class      = "db.t3.micro"
db_allocated_storage   = 20
db_name                = "todoapp"
db_username            = "todo_admin"
db_skip_final_snapshot = true
db_deletion_protection = false
