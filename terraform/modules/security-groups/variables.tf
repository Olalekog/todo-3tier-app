variable "project_name" {
  description = "Project name used for naming resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment such as dev, uat, or prod."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created."
  type        = string
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access the frontend over HTTP."
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_frontend" {
  description = "Create the frontend security group."
  type        = bool
  default     = true
}

variable "enable_backend" {
  description = "Create the backend security group."
  type        = bool
  default     = true
}

variable "enable_database" {
  description = "Create the database security group."
  type        = bool
  default     = true
}

variable "enable_sonarqube" {
  description = "Create the SonarQube security group."
  type        = bool
  default     = false
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access EC2 instances over SSH. Use your public IP with /32."
  type        = string
}

variable "sonarqube_allowed_cidr" {
  description = "CIDR block allowed to access SonarQube web UI and SSH. Defaults to the SSH CIDR when omitted."
  type        = string
  default     = ""
}

variable "backend_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the backend application port. Usually private app subnet CIDRs."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
