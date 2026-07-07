variable "project_name" {
  description = "Project name used for naming resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment such as dev, uat, or prod."
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the compute module user data template."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created."
  type        = string
}

variable "sonarqube_subnet_id" {
  description = "Subnet ID where SonarQube will run. Use a private app subnet to avoid public exposure."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for SonarQube EC2 instance."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SonarQube and SSH."
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair name."
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

variable "user_data_template_path" {
  description = "Path to user data template for SonarQube provisioning."
  type        = string
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}