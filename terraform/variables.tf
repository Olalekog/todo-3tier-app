variable "aws_region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for naming and tagging resources."
  type        = string
  default     = "react-js-application"
}

variable "environment" {
  description = "Deployment environment such as dev, uat, or prod."
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be one of: dev, uat, prod."
  }
}

variable "az_count" {
  description = "Number of Availability Zones to use for subnet creation."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be between 2 and 3."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 instances. Use your public IP with /32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access the frontend application over HTTP."
  type        = string
  default     = "0.0.0.0/0"
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

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access. Set to null if not using SSH keys."
  type        = string
  default     = null
}

variable "image_tag" {
  description = "Docker image tag to deploy from ECR."
  type        = string
  default     = "latest"
}

variable "db_name" {
  description = "Initial MySQL database name."
  type        = string
  default     = "todoapp"
}

variable "db_username" {
  description = "MySQL master username."
  type        = string
  default     = "todo_admin"
}

variable "db_password" {
  description = "MySQL master password. Store this in GitHub Secrets."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS MySQL instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS MySQL in GB."
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "MySQL engine version."
  type        = string
  default     = "8.0"
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip final snapshot when deleting the RDS instance."
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for RDS. Recommended true for prod."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all supported resources."
  type        = map(string)
  default     = {}
}

variable "backend_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the backend."
  type        = list(string)
  default     = []
}