resource "aws_lb" "this" {
  count              = var.enable_alb ? 1 : 0
  name               = substr("${var.project_name}-${var.environment}-alb", 0, 32)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb"
    Tier = "alb"
  })
}

resource "aws_lb_target_group" "frontend" {
  count       = var.enable_alb ? 1 : 0
  name        = substr("${var.project_name}-${var.environment}-front-tg", 0, 32)
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-frontend-tg"
  })
}

resource "aws_lb_target_group_attachment" "frontend" {
  count            = var.enable_alb ? 1 : 0
  target_group_arn = aws_lb_target_group.frontend[0].arn
  target_id        = var.frontend_instance_id
  port             = 80
}

resource "aws_lb_listener" "http" {
  count             = var.enable_alb ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend[0].arn
  }
}
