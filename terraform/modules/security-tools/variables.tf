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

variable "public_subnet_id" {
  description = "Public subnet ID used for integration tooling resources."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for integration tooling EC2 instances."
  type        = string
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access the frontend over HTTP."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access EC2 instances over SSH. Use your public IP with /32."
  type        = string
}

variable "backend_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the backend application port. Usually private app subnet CIDRs."
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Optional EC2 key pair name for integration instances."
  type        = string
  default     = ""
}

variable "enable_sonarqube" {
  description = "Deploy a dedicated SonarQube EC2 instance for source code scanning."
  type        = bool
  default     = false
}

variable "sonarqube_instance_type" {
  description = "EC2 instance type for the SonarQube server. Minimum t3.medium recommended."
  type        = string
  default     = "t3.medium"
}

variable "sonarqube_version" {
  description = "SonarQube Community Edition version to install."
  type        = string
  default     = "10.4.1.88267"
}

variable "sonarqube_user_data_template_path" {
  description = "Path to the user data template used to install SonarQube."
  type        = string
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
