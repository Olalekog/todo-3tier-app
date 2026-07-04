variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "react-js-application"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.40.0.0/16"
}

variable "az_count" {
  description = "Number of AZs/subnet groups to create"
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs for frontend and NAT Gateway"
  type        = list(string)
  default     = ["10.40.1.0/24", "10.40.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Private app subnet CIDRs for backend"
  type        = list(string)
  default     = ["10.40.11.0/24", "10.40.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "Private DB subnet CIDRs for RDS"
  type        = list(string)
  default     = ["10.40.21.0/24", "10.40.22.0/24"]
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to access the frontend over HTTP"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to EC2 instances. Set to your IP/32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access. Leave null to disable SSH key injection."
  type        = string
  default     = null
}

variable "frontend_instance_type" {
  description = "EC2 instance type for the frontend workload"
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "EC2 instance type for the backend workload"
  type        = string
  default     = "t3.micro"
}


variable "image_tag" {
  description = "Docker image tag deployed to EC2 instances."
  type        = string
  default     = "latest"
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "tododb"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "todo_admin"
}

variable "db_password" {
  description = "RDS master password. Use terraform.tfvars locally or DB_PASSWORD GitHub secret in GitHub Actions."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
