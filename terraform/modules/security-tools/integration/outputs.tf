output "sonarqube_url" {
  description = "SonarQube URL (only set when enable_sonarqube = true)."
  value       = length(aws_instance.sonarqube) > 0 ? "http://${aws_instance.sonarqube[0].public_ip}:9000" : null
}
