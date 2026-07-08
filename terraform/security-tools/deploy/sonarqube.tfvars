# Shared SonarQube infrastructure settings, merged with dev.tfvars in the SonarQube workflow.
enable_sonarqube        = true
sonarqube_instance_type = "t3.medium"
sonarqube_version       = "10.4.1.88267"

# Override these with pushed images from terraform/security-tools/prometheus and terraform/security-tools/grafana.
# prometheus_image = "<registry>/security-tools/prometheus:latest"
# grafana_image    = "<registry>/security-tools/grafana:latest"
