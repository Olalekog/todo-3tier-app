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
  description = "Public subnet ID where the security tools EC2 instance will run."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for SonarQube EC2 instance."
  type        = string
  default     = ""
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
  description = "Legacy SonarQube version value. Prefer sonarqube_image for the container deployment."
  type        = string
  default     = "10.4.1.88267"
}

variable "sonarqube_image" {
  description = "SonarQube container image to run on the security tools EC2 instance."
  type        = string
  default     = "sonarqube:community"
}

variable "trivy_image" {
  description = "Trivy container image to run on the security tools EC2 instance."
  type        = string
  default     = "aquasec/trivy:latest"
}

variable "checkov_image" {
  description = "Checkov container image to run on the security tools EC2 instance."
  type        = string
  default     = "bridgecrew/checkov:latest"
}

variable "prometheus_image" {
  description = "Prometheus container image to run on the SonarQube EC2 instance."
  type        = string
  default     = "prom/prometheus:latest"
}

variable "grafana_image" {
  description = "Grafana container image to run on the SonarQube EC2 instance."
  type        = string
  default     = "grafana/grafana-oss:latest"
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
