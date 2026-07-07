output "alb_dns_name" {
  description = "ALB DNS name when enabled."
  value       = length(aws_lb.this) > 0 ? aws_lb.this[0].dns_name : null
}

output "alb_arn" {
  description = "ALB ARN when enabled."
  value       = length(aws_lb.this) > 0 ? aws_lb.this[0].arn : null
}
