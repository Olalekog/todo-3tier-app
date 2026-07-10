# Shared security tools infrastructure settings.
enable_sonarqube        = true
sonarqube_instance_type = "t3.large"

# Security tools are deployed as containers on the same EC2 instance.
sonarqube_image = "sonarqube:community"
trivy_image     = "aquasec/trivy:latest"
checkov_image   = "bridgecrew/checkov:latest"

# Optional monitoring containers.
# prometheus_image = "prom/prometheus:latest"
# grafana_image    = "grafana/grafana-oss:latest"
