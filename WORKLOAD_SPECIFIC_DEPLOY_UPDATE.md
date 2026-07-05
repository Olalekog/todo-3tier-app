# Workload-Specific Docker Image Deployment Update

This package updates the application deployment so frontend and backend image changes are handled independently.

## Behavior

- A frontend image change builds/pushes only the frontend image and triggers Terraform with `workload=frontend`.
- A backend image change builds/pushes only the backend image and triggers Terraform with `workload=backend`.
- Terraform targets only the changed compute module for image-only deployment:
  - `module.frontend_compute`
  - `module.backend_compute`
- Terraform infrastructure changes still run through the normal deploy workflow.

## Terraform updates

The root `terraform/main.tf` now uses separate image tag variables:

```hcl
frontend_image_uri = "${module.ecr.frontend_repository_url}:${var.frontend_image_tag}"
backend_image_uri  = "${module.ecr.backend_repository_url}:${var.backend_image_tag}"
```

The root `terraform/variables.tf` includes:

```hcl
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
```

## Duplicate-file cleanup

The following example files must not exist in the Terraform root because Terraform loads every `*.tf` file:

```text
terraform/locals-image-uri-example.tf
terraform/variables-image-tags.tf
```

They have been removed from this package.
