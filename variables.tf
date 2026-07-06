variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name."
  type        = string
  default     = "react-js-application"
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "az_count" {
  description = "Number of Availability Zones to use."
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "Private application subnet CIDR blocks."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "Private database subnet CIDR blocks."
  type        = list(string)
}

variable "frontend_instance_type" {
  description = "Frontend EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "Backend EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional EC2 key pair name. Use empty string if not required."
  type        = string
  default     = ""
}

variable "allowed_http_cidr_blocks" {
  description = "CIDR blocks allowed to access frontend HTTP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "backend_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access backend port 8000."
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "RDS database name."
  type        = string
  default     = "todoapp"
}

variable "db_username" {
  description = "RDS database username."
  type        = string
  default     = "todo_admin"
}

variable "db_password" {
  description = "RDS database password."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated RDS storage in GB."
  type        = number
  default     = 20
}

variable "frontend_image_tag" {
  description = "Frontend Docker image tag."
  type        = string
  default     = "latest"
}

variable "backend_image_tag" {
  description = "Backend Docker image tag."
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
