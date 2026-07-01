output "frontend_instance_id" {
  value = aws_instance.frontend.id
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_instance_id" {
  value = aws_instance.backend.id
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}

output "ec2_ecr_pull_role_arn" {
  value = aws_iam_role.ec2_ecr_pull.arn
}
