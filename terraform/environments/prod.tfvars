environment = "prod"

vpc_cidr = "10.40.0.0/16"

public_subnet_cidrs = [
  "10.40.1.0/24",
  "10.40.2.0/24"
]

private_app_subnet_cidrs = [
  "10.40.11.0/24",
  "10.40.12.0/24"
]

private_db_subnet_cidrs = [
  "10.40.21.0/24",
  "10.40.22.0/24"
]

frontend_instance_type = "t3.small"
backend_instance_type  = "t3.small"

db_instance_class      = "db.t3.micro"
db_allocated_storage   = 20
db_name                = "todoapp"
db_username            = "todo_admin"
db_skip_final_snapshot = false
db_deletion_protection = true
