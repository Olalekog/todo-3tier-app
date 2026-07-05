variable "frontend_image_tag" {
  description = "Docker image tag for the frontend workload."
  type        = string
  default     = "latest"
}

variable "backend_image_tag" {
  description = "Docker image tag for the backend workload."
  type        = string
  default     = "latest"
}

# Optional backwards compatibility. Remove after all workflows stop passing image_tag.
variable "image_tag" {
  description = "Deprecated shared image tag. Use frontend_image_tag and backend_image_tag instead."
  type        = string
  default     = "latest"
}
