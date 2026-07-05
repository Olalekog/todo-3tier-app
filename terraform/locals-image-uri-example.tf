locals {
  ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"

  frontend_image_uri = "${local.ecr_registry}/${var.project_name}/${var.environment}/todo-frontend:${var.frontend_image_tag}"
  backend_image_uri  = "${local.ecr_registry}/${var.project_name}/${var.environment}/todo-backend:${var.backend_image_tag}"
}
