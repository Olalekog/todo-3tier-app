variable "project_name" {
  description = "Project name used for ECR repository naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
