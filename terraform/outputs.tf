output "frontend_public_ip" {
  description = "Frontend EC2 public IP."
  value       = module.frontend_compute.public_ip
}

output "frontend_instance_id" {
  description = "Frontend EC2 instance ID."
  value       = module.frontend_compute.instance_id
}

output "backend_instance_id" {
  description = "Backend EC2 instance ID."
  value       = module.backend_compute.instance_id
}

output "backend_private_ip" {
  description = "Backend EC2 private IP."
  value       = module.backend_compute.private_ip
}

output "db_address" {
  description = "RDS endpoint address."
  value       = module.database.db_address
}

output "db_name" {
  description = "Application database name."
  value       = var.db_name
}

output "db_username" {
  description = "Application database username."
  value       = var.db_username
}

output "frontend_url" {
  description = "Frontend URL."
  value       = "http://${module.frontend_compute.public_ip}"
}
