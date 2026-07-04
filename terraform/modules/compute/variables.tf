variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "frontend_instance_type" {
  description = "EC2 instance type for the frontend workload"
  type        = string
}

variable "backend_instance_type" {
  description = "EC2 instance type for the backend workload"
  type        = string
}

variable "key_name" {
  type    = string
  default = null
}

variable "frontend_subnet_id" {
  type = string
}

variable "backend_subnet_id" {
  type = string
}

variable "frontend_security_group_id" {
  type = string
}

variable "backend_security_group_id" {
  type = string
}

variable "frontend_image_uri" {
  description = "Full frontend Docker image URI, including tag."
  type        = string
}

variable "backend_image_uri" {
  description = "Full backend Docker image URI, including tag."
  type        = string
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "user_data_frontend_path" {
  type = string
}

variable "user_data_backend_path" {
  type = string
}

variable "tags" {
  type = map(string)
}