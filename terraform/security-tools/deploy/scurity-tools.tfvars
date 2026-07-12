# Shared security tools infrastructure settings.
enable_sonarqube        = true
sonarqube_instance_type = "t3.large"

allowed_http_cidr                 = "0.0.0.0/0"
allowed_ssh_cidr                  = "0.0.0.0/0"
tcp_protocol                      = "tcp"
frontend_http_port                = 80
backend_api_port                  = 8000
database_port                     = 3306
outbound_http_port                = 80
outbound_https_port               = 443
app_outbound_cidr_ipv4            = "0.0.0.0/0"
sonarqube_port                    = 9000
grafana_port                      = 3000
prometheus_port                   = 9090
trivy_port                        = 4954
ssh_port                          = 22
security_tools_outbound_cidr_ipv4 = "0.0.0.0/0"

# Security tools are deployed as containers on the same EC2 instance.
sonarqube_image = "sonarqube:community"
trivy_image     = "aquasec/trivy:latest"
checkov_image   = "bridgecrew/checkov:latest"

# Optional monitoring containers.
# prometheus_image = "prom/prometheus:latest"
# grafana_image    = "grafana/grafana-oss:latest"
