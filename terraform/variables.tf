variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name."
  type        = string
  default     = "react-js-application"
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "az_count" {
  description = "Number of Availability Zones to use."
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "Private app subnet CIDR blocks."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "Private DB subnet CIDR blocks."
  type        = list(string)
}

variable "frontend_instance_type" {
  description = "Frontend EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "Backend EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = ""
}

variable "allowed_http_cidr" {
  description = "CIDR block allowed to access frontend HTTP."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access EC2 instances over SSH."
  type        = string
}

variable "backend_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access backend port 8000."
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

variable "db_name" {
  description = "RDS database name."
  type        = string
  default     = "todoapp"
}

variable "db_username" {
  description = "RDS database username."
  type        = string
  default     = "todo_admin"
}

variable "db_password" {
  description = "RDS database password."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated RDS storage in GB."
  type        = number
  default     = 20
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for the RDS instance."
  type        = bool
  default     = true
}

variable "frontend_image_tag" {
  description = "Frontend Docker image tag."
  type        = string
  default     = "latest"
}

variable "backend_image_tag" {
  description = "Backend Docker image tag."
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
