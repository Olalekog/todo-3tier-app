output "frontend_public_ip" {
  description = "Public IP of the React frontend EC2 instance"
  value       = module.compute.frontend_public_ip
}

output "frontend_url" {
  description = "HTTP URL for the To-Do application"
  value       = "http://${module.compute.frontend_public_ip}"
}

output "backend_private_ip" {
  description = "Private IP of the FastAPI backend EC2 instance"
  value       = module.compute.backend_private_ip
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.database.db_endpoint
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL"
  value       = module.ecr.frontend_repository_url
}

output "backend_ecr_repository_url" {
  description = "Backend ECR repository URL"
  value       = module.ecr.backend_repository_url
}

output "ec2_ecr_pull_role_arn" {
  description = "IAM role ARN used by EC2 instances to pull Docker images from ECR"
  value       = module.compute.ec2_ecr_pull_role_arn
}
