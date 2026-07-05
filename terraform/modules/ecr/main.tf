resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}/${var.environment}/todo-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-todo-frontend"
    App  = "todo-frontend"
  })
}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}/${var.environment}/todo-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-todo-backend"
    App  = "todo-backend"
  })
}
