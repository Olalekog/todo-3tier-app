output "frontend_security_group_id" {
  description = "Frontend security group ID."
  value       = module.deploy.frontend_security_group_id
}

output "backend_security_group_id" {
  description = "Backend security group ID."
  value       = module.deploy.backend_security_group_id
}

output "database_security_group_id" {
  description = "Database security group ID."
  value       = module.deploy.database_security_group_id
}

output "sonarqube_url" {
  description = "SonarQube URL (only set when enable_sonarqube = true)."
  value       = module.integration.sonarqube_url
}
