variable "project_name" {
  description = "Project name used for naming compute resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment such as dev, uat, or prod."
  type        = string
}

variable "workload_name" {
  description = "Workload name for this compute instance, for example frontend or backend."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for this workload."
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be deployed."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to the EC2 instance."
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the EC2 instance."
  type        = bool
  default     = false
}

variable "image_uri" {
  description = "Docker image URI to run on the EC2 instance."
  type        = string
}

variable "user_data_template_path" {
  description = "Path to the user data template for this workload."
  type        = string
}

variable "db_host" {
  description = "Database hostname. Required for backend; blank for frontend."
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Database name. Required for backend; blank for frontend."
  type        = string
  default     = ""
}

variable "db_username" {
  description = "Database username. Required for backend; blank for frontend."
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Database password. Required for backend; blank for frontend."
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Common tags to apply to compute resources."
  type        = map(string)
  default     = {}
}
