# Trivy Security Scan Report

## Project

**Application:** Three-tier To-Do application  
**Security scanner:** Trivy  
**Report scope:** Repository, container images, Dockerfiles, Terraform configuration, licenses, SARIF, and CycloneDX SBOMs

---

## 1. Executive Summary

Trivy completed security scans against the application repository, backend and frontend container images, Dockerfiles, and Terraform infrastructure code.

The scan found **no known dependency or container-image vulnerabilities** and **no exposed secrets**. However, it identified **eight configuration findings** that require review: three critical unrestricted security-group egress rules and five high-severity findings involving public IP assignment and containers running as root.

Trivy also reported restricted-license findings in the container images. These are software-license compliance findings rather than confirmed security vulnerabilities.

| Scan category | Result |
|---|---:|
| Repository vulnerabilities | 0 |
| Backend image vulnerabilities | 0 |
| Frontend image vulnerabilities | 0 |
| Exposed secrets | 0 |
| Configuration findings | 8 |
| Critical configuration findings | 3 |
| High configuration findings | 5 |
| Backend restricted-license findings | 317 |
| Frontend restricted-license findings | 24 |

### Overall status

**Security status: Remediation required**

The application packages and images are currently clean for known CVEs, but the critical infrastructure findings should be corrected before a production deployment.

---

## 2. Reports Included

The Trivy report bundle contains the following outputs:

```text
trivy-security-reports/
├── config/
│   ├── config-table.txt
│   ├── config.json
│   └── config.sarif
├── images/
│   ├── backend-image-table.txt
│   ├── backend-image.json
│   ├── backend-image.sarif
│   ├── frontend-image-table.txt
│   ├── frontend-image.json
│   └── frontend-image.sarif
├── repository/
│   ├── repository-table.txt
│   ├── repository.json
│   └── repository.sarif
└── sbom/
    ├── backend-image-cyclonedx.json
    ├── frontend-image-cyclonedx.json
    └── repository-cyclonedx.json
```

### Report formats

- **Table:** Human-readable scan output
- **JSON:** Detailed machine-readable findings
- **SARIF:** Uploadable to GitHub Code Scanning
- **CycloneDX:** Software Bill of Materials for dependency inventory and compliance review

---

## 3. Scan Results by Severity

| Severity | Findings | Status |
|---|---:|---|
| Critical | 3 | Must remediate or formally approve an exception |
| High | 5 | Remediate before production deployment |
| Medium | 0 | No findings |
| Low | 0 | No findings |

---

## 4. Critical Findings

### 4.1 Frontend security group allows unrestricted outbound traffic

| Field | Value |
|---|---|
| Trivy rule | `AWS-0104` |
| Severity | Critical |
| File | `terraform/modules/security-groups/main.tf` |
| Line | 27 |
| Resource | `aws_security_group.frontend` |
| Finding | Security-group egress permits traffic to `0.0.0.0/0` |

Current configuration:

```hcl
cidr_blocks = ["0.0.0.0/0"]
```

#### Risk

Unrestricted egress allows the frontend instance to initiate connections to any public IPv4 destination. If the instance or application is compromised, this may enable command-and-control communication, malware downloads, data exfiltration, or access to unauthorized external services.

#### Recommended remediation

Restrict outbound traffic to only the destinations, protocols, and ports required by the frontend. For example, permit communication to the backend security group on the backend application port and allow HTTPS only where external access is genuinely required.

---

### 4.2 Backend security group allows unrestricted outbound traffic

| Field | Value |
|---|---|
| Trivy rule | `AWS-0104` |
| Severity | Critical |
| File | `terraform/modules/security-groups/main.tf` |
| Line | 68 |
| Resource | `aws_security_group.backend` |
| Finding | Security-group egress permits traffic to `0.0.0.0/0` |

Current configuration:

```hcl
cidr_blocks = ["0.0.0.0/0"]
```

#### Risk

The backend can connect to any public IPv4 address. A compromised backend could communicate with unauthorized external systems or exfiltrate application and database data.

#### Recommended remediation

Restrict backend outbound traffic according to application requirements. Typical permitted traffic may include:

- MySQL on TCP port `3306` to the database security group
- HTTPS on TCP port `443` to approved AWS services or external APIs
- DNS through the VPC resolver
- Package repositories only during controlled image-building processes

Example database egress rule:

```hcl
resource "aws_vpc_security_group_egress_rule" "backend_to_database" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.database.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "Allow backend access to MySQL"
}
```

---

### 4.3 Database security group allows unrestricted outbound traffic

| Field | Value |
|---|---|
| Trivy rule | `AWS-0104` |
| Severity | Critical |
| File | `terraform/modules/security-groups/main.tf` |
| Line | 98 |
| Resource | `aws_security_group.database` |
| Finding | Security-group egress permits traffic to `0.0.0.0/0` |

Current configuration:

```hcl
cidr_blocks = ["0.0.0.0/0"]
```

#### Risk

The database security group permits unrestricted outbound traffic even though the database tier normally requires very limited network access.

#### Recommended remediation

Remove the unrestricted egress rule unless a documented database requirement depends on it. The RDS security group should primarily allow inbound MySQL traffic from the backend security group only.

Example inbound rule:

```hcl
resource "aws_vpc_security_group_ingress_rule" "database_from_backend" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "Allow MySQL access from backend only"
}
```

Recommended application flow:

```text
Internet
   |
   v
Frontend security group
   |
   v
Backend security group
   |
   v
Database security group
```

---

## 5. High-Severity Findings

### 5.1 Public subnets automatically assign public IP addresses

| Field | Value |
|---|---|
| Trivy rule | `AWS-0164` |
| Severity | High |
| File | `terraform/modules/network/main.tf` |
| Line | 36 |
| Resource | `aws_subnet.public` |
| Finding | `map_public_ip_on_launch = true` |

Current configuration:

```hcl
map_public_ip_on_launch = true
```

#### Risk

Any compatible resource launched in the subnet may automatically receive a public IP address. This increases the possibility of unintended internet exposure.

#### Production recommendation

Disable automatic public IP assignment:

```hcl
resource "aws_subnet" "public" {
  # Existing subnet configuration

  map_public_ip_on_launch = false
}
```

Use an Application Load Balancer as the public entry point and place application EC2 instances in private subnets.

#### Simplified-project exception

The current simplified architecture intentionally places the frontend EC2 instance in a public subnet. When this design is required for training or demonstration purposes, document the exception and suppress only the specific accepted finding:

```hcl
resource "aws_subnet" "public" {
  # trivy:ignore:AWS-0164 -- Public frontend required by the simplified project design
  map_public_ip_on_launch = true
}
```

A suppression should include a business or architectural justification and should not be used merely to make the scan pass.

---

### 5.2 Backend container runs as root

| Field | Value |
|---|---|
| Trivy rule | `DS-0002` |
| Severity | High |
| File | `backend/Dockerfile` |
| Finding | Dockerfile does not specify a non-root `USER` |

#### Risk

A process running as root inside a container has greater privileges than necessary. If the application is compromised, the impact of container escape or filesystem modification may be greater.

#### Recommended remediation

Create and use a dedicated non-root user:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN groupadd --system appgroup \
    && useradd --system --gid appgroup appuser \
    && chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

### 5.3 Frontend container runs as root

| Field | Value |
|---|---|
| Trivy rule | `DS-0002` |
| Severity | High |
| File | `frontend/Dockerfile` |
| Finding | Dockerfile does not specify a non-root `USER` |

#### Recommended remediation

For an Nginx-based frontend, use an unprivileged image and expose a non-privileged port:

```dockerfile
FROM node:20-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginxinc/nginx-unprivileged:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 8080
```

Confirm whether the frontend build output is located in `dist` or `build`, and update the `COPY` path accordingly.

---

### 5.4 Grafana container runs as root

| Field | Value |
|---|---|
| Trivy rule | `DS-0002` |
| Severity | High |
| File | `terraform/security-tools/grafana/Dockerfile` |
| Finding | Dockerfile does not specify a non-root `USER` |

#### Recommended remediation

Use the non-root user provided by the official Grafana image or explicitly restore the correct user at the end of the custom Dockerfile.

Example:

```dockerfile
FROM grafana/grafana:latest

# Custom configuration steps

USER grafana
```

Pin the production image to a tested version or digest instead of using `latest`.

---

### 5.5 Prometheus container runs as root

| Field | Value |
|---|---|
| Trivy rule | `DS-0002` |
| Severity | High |
| File | `terraform/security-tools/prometheus/Dockerfile` |
| Finding | Dockerfile does not specify a non-root `USER` |

#### Recommended remediation

Use the non-root user supported by the selected Prometheus base image and ensure that configuration and data directories are writable by that user.

Example pattern:

```dockerfile
FROM prom/prometheus:latest

# Custom configuration steps

USER nobody
```

Verify the correct user for the exact base-image version before applying the change. Pin the image to a tested version or digest.

---

## 6. Vulnerability Results

### Repository dependencies

Trivy found **zero known vulnerabilities** in the scanned repository dependencies, including the detected Python and Node.js package manifests.

| Target | Result |
|---|---:|
| Backend Python dependencies | 0 vulnerabilities |
| Frontend Node.js dependencies | 0 vulnerabilities |

### Backend container image

| Category | Result |
|---|---:|
| Operating-system package vulnerabilities | 0 |
| Application dependency vulnerabilities | 0 |
| Restricted-license findings | 317 high |

### Frontend container image

| Category | Result |
|---|---:|
| Operating-system package vulnerabilities | 0 |
| Application dependency vulnerabilities | 0 |
| Restricted-license findings | 24 high |

### Important limitation

A clean vulnerability report means that Trivy did not detect known vulnerabilities using the vulnerability database available at scan time. It does not guarantee that the application is free from unknown vulnerabilities, insecure business logic, SQL injection, cross-site scripting, authentication defects, or runtime configuration risks.

Continue using SonarQube or another SAST tool for source-code security analysis and consider DAST testing against a deployed environment.

---

## 7. Secret-Scanning Results

Trivy detected **zero exposed secrets** in the scanned repository.

This result should be supplemented with preventive controls:

- Store credentials in AWS Secrets Manager or GitHub Actions secrets.
- Never commit `.env` files containing real credentials.
- Enable GitHub secret scanning where available.
- Rotate any credential immediately if it is accidentally committed.
- Avoid placing secrets in Terraform variables, outputs, user-data scripts, or workflow logs.

---

## 8. License Findings

Trivy reported the following restricted-license findings:

| Image | Restricted-license findings | Severity assigned by policy |
|---|---:|---|
| Backend | 317 | High |
| Frontend | 24 | High |

These findings are not CVEs and do not necessarily indicate exploitable security weaknesses. They identify packages whose licenses require review under the configured compliance policy. Examples may include GPL and LGPL license families.

### Recommended response

- **Internal training application:** Record the findings and determine whether the policy accepts internal use.
- **Commercial distribution:** Request legal or open-source compliance review.
- **Public container publication:** Review attribution, notice, source-code, and redistribution obligations.
- **CI/CD enforcement:** Keep license policy separate from the vulnerability security gate unless organizational policy requires deployment blocking.

The CycloneDX SBOM files can be used to inventory the included packages and support the license review.

---

## 9. Remediation Priority

| Priority | Action | Severity |
|---:|---|---|
| 1 | Remove or restrict unrestricted database security-group egress | Critical |
| 2 | Restrict backend security-group egress | Critical |
| 3 | Restrict frontend security-group egress | Critical |
| 4 | Configure all four Dockerfiles to run as non-root | High |
| 5 | Disable automatic public IP assignment or document the approved exception | High |
| 6 | Review restricted licenses under the organization’s compliance policy | Compliance |
| 7 | Rerun Trivy and upload updated SARIF reports | Verification |

---

## 10. Recommended CI/CD Security Gate

Use separate scans for enforcement and reporting.

### Enforcement scan

This scan fails the workflow when Trivy detects high or critical vulnerabilities or misconfigurations:

```yaml
- name: Enforce Trivy security gate
  uses: aquasecurity/trivy-action@<PINNED_COMMIT_SHA>
  with:
    scan-type: fs
    scan-ref: .
    scanners: vuln,secret,misconfig
    severity: HIGH,CRITICAL
    ignore-unfixed: true
    format: table
    exit-code: 1
```

### SARIF reporting scan

This scan generates results for GitHub Code Scanning without stopping report upload:

```yaml
- name: Generate Trivy SARIF report
  uses: aquasecurity/trivy-action@<PINNED_COMMIT_SHA>
  with:
    scan-type: fs
    scan-ref: .
    scanners: vuln,secret,misconfig
    severity: LOW,MEDIUM,HIGH,CRITICAL
    format: sarif
    output: trivy-results.sarif
    exit-code: 0

- name: Upload Trivy results to GitHub
  if: always()
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: trivy-results.sarif
```

Required workflow permissions:

```yaml
permissions:
  contents: read
  security-events: write
```

Pin third-party GitHub Actions to verified full commit SHAs for stronger supply-chain protection.

---

## 11. Commands to Rerun the Scans

### Scan the entire repository

```bash
trivy fs \
  --scanners vuln,secret,misconfig,license \
  --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL \
  .
```

### Scan configuration files

```bash
trivy config \
  --severity HIGH,CRITICAL \
  .
```

### Scan the backend image

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  todo-backend:latest
```

### Scan the frontend image

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  todo-frontend:latest
```

### Generate a JSON report

```bash
trivy fs \
  --scanners vuln,secret,misconfig,license \
  --format json \
  --output trivy-report.json \
  .
```

### Generate a SARIF report

```bash
trivy fs \
  --scanners vuln,secret,misconfig \
  --format sarif \
  --output trivy-results.sarif \
  .
```

### Generate a CycloneDX SBOM

```bash
trivy fs \
  --format cyclonedx \
  --output repository-cyclonedx.json \
  .
```

---

## 12. Verification Checklist

After remediation, confirm the following:

- [ ] Frontend security-group egress is restricted to required destinations.
- [ ] Backend security-group egress is restricted to required destinations.
- [ ] Database unrestricted egress is removed.
- [ ] Database ingress accepts MySQL only from the backend security group.
- [ ] Backend Dockerfile runs as a non-root user.
- [ ] Frontend Dockerfile runs as a non-root user.
- [ ] Grafana Dockerfile runs as the appropriate non-root user.
- [ ] Prometheus Dockerfile runs as the appropriate non-root user.
- [ ] Public IP assignment is disabled or has an approved, documented exception.
- [ ] Repository vulnerability count remains zero.
- [ ] Backend image vulnerability count remains zero.
- [ ] Frontend image vulnerability count remains zero.
- [ ] No secrets are detected.
- [ ] License findings are reviewed according to organizational policy.
- [ ] Updated SARIF results appear in GitHub **Security → Code scanning**.

---

## 13. Final Assessment

The current Trivy scan shows a strong result for software dependencies and container-image vulnerabilities: no known CVEs or exposed secrets were detected. The main risks are infrastructure and container hardening issues.

The three critical unrestricted egress findings should be remediated first. The four containers should then be configured to run as non-root users, and the public-IP setting should either be removed for a production architecture or documented as a controlled exception for the simplified training design.

After these changes, rerun all Trivy scans and retain the JSON, SARIF, table, and SBOM outputs as security evidence.
