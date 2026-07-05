output "frontend_instance_id" {
  description = "Frontend EC2 instance ID."
  value       = module.frontend_compute.instance_id
}

output "frontend_public_ip" {
  description = "Frontend public IP address."
  value       = module.frontend_compute.public_ip
}

output "frontend_public_dns" {
  description = "Frontend public DNS name."
  value       = module.frontend_compute.public_dns
}

output "frontend_url" {
  description = "Frontend application URL."
  value       = "http://${module.frontend_compute.public_ip}"
}

output "backend_instance_id" {
  description = "Backend EC2 instance ID."
  value       = module.backend_compute.instance_id
}

output "backend_private_ip" {
  description = "Backend private IP address."
  value       = module.backend_compute.private_ip
}

output "database_endpoint" {
  description = "RDS database endpoint."
  value       = module.database.db_address
}

output "frontend_repository_url" {
  description = "Frontend ECR repository URL."
  value       = module.ecr.frontend_repository_url
}

output "backend_repository_url" {
  description = "Backend ECR repository URL."
  value       = module.ecr.backend_repository_url
}
