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
  description = "CIDR block allowed to access SonarQube web UI and SSH. Defaults to the SSH CIDR when omitted and is intended for public access with a restricted CIDR."
  type        = string
  default     = ""
}

variable "backend_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the backend application port. Usually private app subnet CIDRs."
  type        = list(string)
  default     = []
}

variable "tcp_protocol" {
  description = "IP protocol used by TCP security group rules."
  type        = string
}

variable "frontend_http_port" {
  description = "Frontend HTTP listener port."
  type        = number
}

variable "backend_api_port" {
  description = "Backend API listener port."
  type        = number
}

variable "database_port" {
  description = "Database listener port."
  type        = number
}

variable "outbound_http_port" {
  description = "HTTP outbound port for package repositories and public HTTP endpoints."
  type        = number
}

variable "outbound_https_port" {
  description = "HTTPS outbound port for ECR, SSM, package downloads, and updates."
  type        = number
}

variable "app_outbound_cidr_ipv4" {
  description = "IPv4 CIDR allowed for application outbound HTTP and HTTPS dependencies."
  type        = string
}

variable "sonarqube_port" {
  description = "SonarQube web UI port."
  type        = number
}

variable "grafana_port" {
  description = "Grafana web UI port."
  type        = number
}

variable "prometheus_port" {
  description = "Prometheus web UI port."
  type        = number
}

variable "trivy_port" {
  description = "Trivy server API port."
  type        = number
}

variable "ssh_port" {
  description = "SSH management port."
  type        = number
}

variable "security_tools_outbound_cidr_ipv4" {
  description = "IPv4 CIDR allowed for security tools outbound HTTP and HTTPS dependencies."
  type        = string
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
