variable "project_name" {
  description = "Project name used for naming resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment such as dev, uat, or prod."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB resources will be created."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to ALB."
  type        = string
}

variable "frontend_instance_id" {
  description = "Frontend EC2 instance ID for target registration."
  type        = string
}

variable "enable_alb" {
  description = "Whether to create ALB resources."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
