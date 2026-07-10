variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "name_suffix" {
  description = "Optional suffix added to database resource names."
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID that must contain the database subnets and security group."
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private database subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "private_db_subnet_vpc_ids" {
  description = "VPC IDs for the private database subnets."
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID attached to the database."
  type        = string
}

variable "db_name" {
  description = "Database name."
  type        = string
}

variable "db_username" {
  description = "Database master username."
  type        = string
}

variable "db_password" {
  description = "Database master password."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage size in GB."
  type        = number
}

variable "engine_version" {
  description = "MySQL engine version."
  type        = string
  default     = "8.0"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "RDS backup retention period in days."
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to database resources."
  type        = map(string)
  default     = {}
}
