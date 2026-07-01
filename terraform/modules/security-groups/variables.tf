variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "allowed_http_cidr" { type = string }
variable "allowed_ssh_cidr" { type = string }
variable "tags" { type = map(string) }
