output "sonarqube_url" {
  description = "Public SonarQube URL for the security tools EC2 instance."
  value       = var.enable_sonarqube ? "http://${module.sonarqube_compute[0].public_ip}:9000" : null
}

output "security_tools_public_ip" {
  description = "Public IP of the security tools EC2 instance."
  value       = var.enable_sonarqube ? module.sonarqube_compute[0].public_ip : null
}

output "trivy_server_url" {
  description = "Public Trivy server URL for the security tools EC2 instance."
  value       = var.enable_sonarqube ? "http://${module.sonarqube_compute[0].public_ip}:4954" : null
}

output "prometheus_url" {
  description = "Public Prometheus URL (only set when enable_sonarqube = true)."
  value       = var.enable_sonarqube ? "http://${module.sonarqube_compute[0].public_ip}:9090" : null
}

output "grafana_url" {
  description = "Public Grafana URL (only set when enable_sonarqube = true)."
  value       = var.enable_sonarqube ? "http://${module.sonarqube_compute[0].public_ip}:3000" : null
}
