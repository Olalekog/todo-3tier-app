aws_region   = "us-east-1"
project_name = "react-js-application"
environment  = "prod"

vpc_cidr = "10.2.0.0/16"
az_count = 2

public_subnet_cidrs      = ["10.2.1.0/24", "10.2.2.0/24"]
private_app_subnet_cidrs = ["10.2.11.0/24", "10.2.12.0/24"]
private_db_subnet_cidrs  = ["10.2.21.0/24", "10.2.22.0/24"]

allowed_http_cidr = "0.0.0.0/0"
allowed_ssh_cidr  = "0.0.0.0/0"

tcp_protocol                      = "tcp"
frontend_http_port                = 80
backend_api_port                  = 8000
database_port                     = 3306
outbound_http_port                = 80
outbound_https_port               = 443
app_outbound_cidr_ipv4            = "0.0.0.0/0"
sonarqube_port                    = 9000
grafana_port                      = 3000
prometheus_port                   = 9090
trivy_port                        = 4954
ssh_port                          = 22
security_tools_outbound_cidr_ipv4 = "0.0.0.0/0"

key_name = ""

frontend_instance_type = "t3.small"
backend_instance_type  = "t3.medium"

frontend_image_tag = "latest"
backend_image_tag  = "latest"

db_name              = "todoapp"
db_username          = "todo_admin"
db_instance_class    = "db.t3.small"
db_allocated_storage = 50

tags = {
  Owner       = "Olalekan"
  Application = "react-js-application"
}
