variable "project_name" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "workload_name" {
  description = "Workload name, for example frontend or backend."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "ami_id" {
  description = "AMI ID."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID."
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP."
  type        = bool
  default     = false
}

variable "image_uri" {
  description = "Full Docker image URI."
  type        = string
}

variable "ecr_repository_arns" {
  description = "Allowed ECR repository ARNs for image pull actions."
  type        = list(string)
  default     = []
}

variable "user_data_template_path" {
  description = "Path to the user data template file."
  type        = string
}

variable "db_host" {
  description = "RDS endpoint for backend workload. Empty for frontend."
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Database name for backend workload. Empty for frontend."
  type        = string
  default     = ""
}

variable "db_username" {
  description = "Database username for backend workload. Empty for frontend."
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Database password for backend workload. Empty for frontend."
  type        = string
  default     = ""
  sensitive   = true
}

variable "backend_private_ip" {
  description = "Backend private IP used by frontend Nginx proxy. Empty for backend workload."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
