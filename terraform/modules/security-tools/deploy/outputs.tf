output "sonarqube_url" {
  description = "SonarQube URL (only set when enable_sonarqube = true)."
  value       = var.enable_sonarqube ? "http://${module.sonarqube_compute[0].public_ip}:9000" : null
}