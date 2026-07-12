locals {
  sonarqube_allowed_cidr = var.sonarqube_allowed_cidr != "" ? var.sonarqube_allowed_cidr : var.allowed_ssh_cidr
}

resource "aws_security_group" "frontend" {
  count = var.enable_frontend ? 1 : 0
  #checkov:skip=CKV_AWS_260:Single-instance frontend is intentionally internet-facing on HTTP.
  #checkov:skip=CKV2_AWS_5:Attachment is defined in root compute module.
  name        = "${var.project_name}-${var.environment}-frontend-sg"
  description = "Frontend security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-frontend-sg"
    Tier = "frontend"
  })
}

resource "aws_security_group" "backend" {
  count = var.enable_backend ? 1 : 0
  #checkov:skip=CKV2_AWS_5:Attachment is defined in root compute module.
  name        = "${var.project_name}-${var.environment}-backend-sg"
  description = "Backend security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-backend-sg"
    Tier = "backend"
  })
}

resource "aws_security_group" "database" {
  count = var.enable_database ? 1 : 0
  #checkov:skip=CKV2_AWS_5:Attachment is defined in root database module.
  name        = "${var.project_name}-${var.environment}-database-sg"
  description = "Database security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-database-sg"
    Tier = "database"
  })
}

resource "aws_security_group" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0
  #checkov:skip=CKV2_AWS_5:Attachment is defined in root compute module.
  name        = "${var.project_name}-${var.environment}-sonarqube-sg"
  description = "SonarQube security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sonarqube-sg"
    Tier = "tools"
  })
}

resource "aws_vpc_security_group_ingress_rule" "frontend_http" {
  count = var.enable_frontend ? 1 : 0

  security_group_id = aws_security_group.frontend[0].id
  description       = "Allow HTTP to frontend"
  from_port         = var.frontend_http_port
  to_port           = var.frontend_http_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = var.allowed_http_cidr
}

resource "aws_vpc_security_group_egress_rule" "frontend_to_backend_api" {
  count = var.enable_frontend && var.enable_backend ? 1 : 0

  security_group_id            = aws_security_group.frontend[0].id
  description                  = "Allow frontend to backend API"
  from_port                    = var.backend_api_port
  to_port                      = var.backend_api_port
  ip_protocol                  = var.tcp_protocol
  referenced_security_group_id = aws_security_group.backend[0].id
}

resource "aws_vpc_security_group_egress_rule" "frontend_http_outbound" {
  count = var.enable_frontend ? 1 : 0

  security_group_id = aws_security_group.frontend[0].id
  description       = "Allow frontend package repository HTTP access"
  from_port         = var.outbound_http_port
  to_port           = var.outbound_http_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = var.app_outbound_cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "frontend_https_outbound" {
  count = var.enable_frontend ? 1 : 0

  security_group_id = aws_security_group.frontend[0].id
  description       = "Allow frontend HTTPS access for ECR, SSM, and package downloads"
  from_port         = var.outbound_https_port
  to_port           = var.outbound_https_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = var.app_outbound_cidr_ipv4
}

resource "aws_vpc_security_group_ingress_rule" "backend_from_frontend_api" {
  count = var.enable_frontend && var.enable_backend ? 1 : 0

  security_group_id            = aws_security_group.backend[0].id
  description                  = "Allow frontend to backend API"
  from_port                    = var.backend_api_port
  to_port                      = var.backend_api_port
  ip_protocol                  = var.tcp_protocol
  referenced_security_group_id = aws_security_group.frontend[0].id
}

resource "aws_vpc_security_group_egress_rule" "backend_to_database_mysql" {
  count = var.enable_backend && var.enable_database ? 1 : 0

  security_group_id            = aws_security_group.backend[0].id
  description                  = "Allow backend to database MySQL"
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = var.tcp_protocol
  referenced_security_group_id = aws_security_group.database[0].id
}

resource "aws_vpc_security_group_egress_rule" "backend_http_outbound" {
  count = var.enable_backend ? 1 : 0

  security_group_id = aws_security_group.backend[0].id
  description       = "Allow backend package repository HTTP access"
  from_port         = var.outbound_http_port
  to_port           = var.outbound_http_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = var.app_outbound_cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "backend_https_outbound" {
  count = var.enable_backend ? 1 : 0

  security_group_id = aws_security_group.backend[0].id
  description       = "Allow backend HTTPS access for ECR, SSM, and package downloads"
  from_port         = var.outbound_https_port
  to_port           = var.outbound_https_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = var.app_outbound_cidr_ipv4
}

resource "aws_vpc_security_group_ingress_rule" "database_from_backend_mysql" {
  count = var.enable_backend && var.enable_database ? 1 : 0

  security_group_id            = aws_security_group.database[0].id
  description                  = "Allow MySQL from backend security group"
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = var.tcp_protocol
  referenced_security_group_id = aws_security_group.backend[0].id
}

resource "aws_vpc_security_group_ingress_rule" "sonarqube_web" {
  count = var.enable_sonarqube ? 1 : 0

  security_group_id = aws_security_group.sonarqube[0].id
  description       = "SonarQube web UI from allowed CIDR"
  from_port         = var.sonarqube_port
  to_port           = var.sonarqube_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = local.sonarqube_allowed_cidr
}

resource "aws_vpc_security_group_ingress_rule" "sonarqube_grafana" {
  count = var.enable_sonarqube ? 1 : 0

  security_group_id = aws_security_group.sonarqube[0].id
  description       = "Grafana web UI from allowed CIDR"
  from_port         = var.grafana_port
  to_port           = var.grafana_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = local.sonarqube_allowed_cidr
}

resource "aws_vpc_security_group_ingress_rule" "sonarqube_prometheus" {
  count = var.enable_sonarqube ? 1 : 0

  security_group_id = aws_security_group.sonarqube[0].id
  description       = "Prometheus web UI from allowed CIDR"
  from_port         = var.prometheus_port
  to_port           = var.prometheus_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = local.sonarqube_allowed_cidr
}

resource "aws_vpc_security_group_ingress_rule" "sonarqube_trivy" {
  count = var.enable_sonarqube ? 1 : 0

  security_group_id = aws_security_group.sonarqube[0].id
  description       = "Trivy server API from allowed CIDR"
  from_port         = var.trivy_port
  to_port           = var.trivy_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = local.sonarqube_allowed_cidr
}

resource "aws_vpc_security_group_ingress_rule" "sonarqube_ssh" {
  count = var.enable_sonarqube ? 1 : 0

  security_group_id = aws_security_group.sonarqube[0].id
  description       = "SSH from allowed CIDR"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = local.sonarqube_allowed_cidr
}

resource "aws_vpc_security_group_egress_rule" "sonarqube_http_outbound" {
  count = var.enable_sonarqube ? 1 : 0

  security_group_id = aws_security_group.sonarqube[0].id
  description       = "Allow security tools package repository HTTP access"
  from_port         = var.outbound_http_port
  to_port           = var.outbound_http_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = var.security_tools_outbound_cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "sonarqube_https_outbound" {
  count = var.enable_sonarqube ? 1 : 0

  security_group_id = aws_security_group.sonarqube[0].id
  description       = "Allow security tools HTTPS access for image pulls and updates"
  from_port         = var.outbound_https_port
  to_port           = var.outbound_https_port
  ip_protocol       = var.tcp_protocol
  cidr_ipv4         = var.security_tools_outbound_cidr_ipv4
}
