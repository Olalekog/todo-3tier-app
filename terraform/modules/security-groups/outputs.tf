output "frontend_security_group_id" {
  description = "Frontend security group ID."
  value       = var.enable_frontend ? aws_security_group.frontend[0].id : null
}

output "backend_security_group_id" {
  description = "Backend security group ID."
  value       = var.enable_backend ? aws_security_group.backend[0].id : null
}

output "database_security_group_id" {
  description = "Database security group ID."
  value       = var.enable_database ? aws_security_group.database[0].id : null
}

output "sonarqube_security_group_id" {
  description = "SonarQube security group ID."
  value       = var.enable_sonarqube ? aws_security_group.sonarqube[0].id : null
}
