output "frontend_public_ip" {
  description = "Frontend EC2 public IP."
  value       = module.frontend_compute.public_ip
}

output "backend_private_ip" {
  description = "Backend EC2 private IP."
  value       = module.backend_compute.private_ip
}

output "db_address" {
  description = "RDS endpoint address."
  value       = module.database.db_address
}

output "frontend_url" {
  description = "Frontend URL."
  value       = "http://${module.frontend_compute.public_ip}"
}
