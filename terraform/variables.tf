variable "aws_region" {
  description = "AWS Region where resources will be deployed."
  type        = string
}

variable "project_name" {
  description = "Project name used for naming and tagging AWS resources."
  type        = string
  default     = "react-js-application"
}

variable "environment" {
  description = "Deployment environment name such as dev, uat, or prod."
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be one of: dev, uat, prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets."
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability Zones used by the VPC subnets."
  type        = list(string)
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the public frontend EC2 instance. Use your public IP with /32."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be a valid CIDR block, for example 203.0.113.10/32."
  }
}

variable "frontend_instance_type" {
  description = "EC2 instance type for the frontend workload."
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "EC2 instance type for the backend workload."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Optional AMI ID for EC2 instances. Leave empty to use the latest Amazon Linux 2023 AMI from SSM."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access. Leave empty if SSH key access is not required."
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Name of the application database."
  type        = string
  default     = "todoapp"
}

variable "db_username" {
  description = "Master username for the RDS MySQL database."
  type        = string
  default     = "todo_admin"
}

variable "db_password" {
  description = "Master password for the RDS MySQL database. Pass this from GitHub Secrets."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS DB instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage size for RDS in GB."
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "MySQL engine version for RDS."
  type        = string
  default     = "8.0"
}

variable "image_tag" {
  description = "Docker image tag to deploy from ECR. Usually latest or the Git commit SHA."
  type        = string
  default     = "latest"
}

variable "frontend_container_port" {
  description = "Container port exposed by the frontend application."
  type        = number
  default     = 80
}

variable "backend_container_port" {
  description = "Container port exposed by the backend application."
  type        = number
  default     = 8000
}

variable "common_tags" {
  description = "Additional common tags applied to resources."
  type        = map(string)
  default     = {}
}