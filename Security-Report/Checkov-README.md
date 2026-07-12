# Checkov Infrastructure-as-Code Security Report

## Project

**Application:** Three-tier To-Do application  
**Scan tool:** Checkov  
**Scanned frameworks:** Terraform, Dockerfile, GitHub Actions, and secrets  
**Source archive:** `checkov-iac-report.zip`

---

## Executive Summary

The Checkov scan shows a strong Terraform security posture. All evaluated Terraform controls passed, with no failed Terraform checks and no parsing errors. The remaining actionable findings are primarily related to container hardening and GitHub Actions manual inputs.

| Framework | Passed | Failed | Skipped | Parsing errors | Assessment |
|---|---:|---:|---:|---:|---|
| Terraform | 132 | 0 | 12 | 0 | Passed |
| Dockerfile | 4 | 8 | 0 | 0 | Remediation required |
| GitHub Actions | 558 | 2 | 0 | 0 | Review workflow inputs |
| Secrets | 0 | 37 | 0 | 0 | Likely scanner-environment false positives |
| **Total** | **694** | **47** | **12** | **0** | Review required |

> The raw total of 47 failed checks is misleading. Thirty-seven secret findings and two Dockerfile findings point to packages installed inside the Checkov runner rather than files under `/repo`. After separating likely scanner-environment noise, the report contains **8 repository-related actionable findings**: six Dockerfile findings and two GitHub Actions findings.

---

## Key Conclusions

- Terraform configuration passed all 132 evaluated security checks.
- No Terraform syntax or parsing errors were reported.
- Twelve Terraform checks were deliberately suppressed with documented reasons.
- Prometheus and Grafana Dockerfiles require image pinning, non-root execution, and health checks.
- Two GitHub Actions deployment workflows allow `workflow_dispatch` inputs that may affect deployment output.
- Secret findings were reported only from Checkov and Botocore installation directories under `/usr/local/lib/python3.11/site-packages`, not the application repository.

---

# 1. Terraform Results

## Status: Passed

```text
Passed checks: 132
Failed checks: 0
Skipped checks: 12
Parsing errors: 0
```

The Terraform scan found no policy violations among the controls that were evaluated. Examples of successful controls include:

- AWS GitHub Actions OIDC trust-policy validation
- AMI selection protection against image-name confusion attacks
- Infrastructure resource security checks
- IAM and networking checks
- Encryption and logging controls represented in the configured Checkov ruleset

## Skipped Terraform Checks

The following controls were intentionally skipped in the Terraform source code.

### CKV_AWS_88 — EC2 instances should not have public IP addresses

Affected resources:

- Backend EC2 instance
- Frontend EC2 instance
- SonarQube EC2 instance

Recorded justification:

```text
Frontend and SonarQube instances are intentionally public-facing in this deployment.
```

### Review note

The skip is understandable for the frontend and SonarQube resources in a simplified lab architecture. The backend instance should normally remain private. Confirm that the backend does not receive a public IP and remove its suppression if public exposure is not required.

Recommended production architecture:

```text
Internet
   |
Application Load Balancer
   |
Private frontend instances
   |
Private backend instances
   |
Private RDS database
```

---

### CKV_AWS_260 — Security groups should not expose port 80 to `0.0.0.0/0`

Affected resource:

```text
module.security_groups.aws_security_group.frontend
```

Recorded justification:

```text
Single-instance frontend is intentionally internet-facing on HTTP.
```

### Review note

For a training or simplified deployment, this exception may be accepted temporarily. For production:

- Place an Application Load Balancer in front of the frontend.
- Redirect HTTP to HTTPS.
- Terminate TLS using an ACM certificate.
- Permit frontend instance traffic only from the load balancer security group.

---

### CKV2_AWS_5 — Security groups should be attached to another resource

Affected security groups:

- Frontend
- Backend
- Database
- SonarQube

Recorded justification:

```text
Attachment is defined in root compute module.
```

or:

```text
Attachment is defined in root database module.
```

These suppressions appear reasonable when Checkov cannot trace cross-module resource attachment. Verify the Terraform plan to confirm each security group is attached to an EC2 instance, network interface, load balancer, or RDS resource.

Useful verification command:

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
checkov -f tfplan.json --framework terraform_plan
```

---

# 2. Dockerfile Findings

## Status: Remediation required

Six repository-related failures affect the Prometheus and Grafana Dockerfiles.

| Check ID | Finding | Prometheus | Grafana |
|---|---|---:|---:|
| CKV_DOCKER_7 | Base image uses `latest` or an unpinned tag | Failed | Failed |
| CKV_DOCKER_3 | No non-root container user is configured | Failed | Failed |
| CKV_DOCKER_2 | No `HEALTHCHECK` instruction is configured | Failed | Failed |

Affected files:

```text
terraform/security-tools/prometheus/Dockerfile
terraform/security-tools/grafana/Dockerfile
```

## 2.1 CKV_DOCKER_7 — Pin container image versions

Avoid mutable image references such as:

```dockerfile
FROM prom/prometheus:latest
```

Use an approved fixed version:

```dockerfile
FROM prom/prometheus:<approved-version>
```

For stronger supply-chain integrity, pin the image digest:

```dockerfile
FROM prom/prometheus:<approved-version>@sha256:<verified-digest>
```

Apply the same approach to Grafana.

### Why this matters

A mutable `latest` tag can change without a source-code change, making deployments non-reproducible and allowing unexpected image contents into the environment.

---

## 2.2 CKV_DOCKER_3 — Run containers as non-root

Checkov did not detect an explicit non-root `USER` instruction.

Prometheus example:

```dockerfile
FROM prom/prometheus:<approved-version>

# Copy configuration while still using the image's setup permissions.
COPY prometheus.yml /etc/prometheus/prometheus.yml

USER nobody

EXPOSE 9090
```

Grafana example:

```dockerfile
FROM grafana/grafana:<approved-version>

USER grafana

EXPOSE 3000
```

> Confirm the users and file permissions supported by the selected official image version. Do not add a user that cannot read the configuration or write to required data directories.

### Why this matters

Running as root increases the impact of a container escape, vulnerable dependency, or application compromise.

---

## 2.3 CKV_DOCKER_2 — Add container health checks

Prometheus example:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:9090/-/healthy || exit 1
```

Grafana example:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/api/health || exit 1
```

Use a health-check command that is actually available in the selected base image. A Docker health check can also be implemented with `curl`, Python, or another preinstalled tool.

---

## Scanner-generated Dockerfile noise

Two Dockerfile findings referenced:

```text
/usr/local/lib/python3.11/site-packages/checkov/common/util/dockerfile.py
```

These findings do not point to a Dockerfile in the application repository and should not be treated as application defects. Limit the scan path to the repository and exclude the runner environment.

Recommended scan:

```bash
checkov -d . \
  --framework terraform,dockerfile,github_actions,secrets \
  --skip-path '.git' \
  --output cli \
  --output json \
  --output-file-path console,checkov-results
```

In GitHub Actions, ensure Checkov scans `${{ github.workspace }}` or `.` rather than the root filesystem.

---

# 3. GitHub Actions Findings

## Status: Review required

Two failures were reported for `CKV_GHA_7`.

| Workflow | Lines | Check |
|---|---:|---|
| `.github/workflows/security-tools-deploy.yml` | 27–46 | CKV_GHA_7 |
| `.github/workflows/app-deploy.yml` | 19–37 | CKV_GHA_7 |

Check description:

```text
GitHub Actions workflow_dispatch inputs must be empty because build output
should not be influenced by arbitrary user-controlled parameters.
```

## Risk

Manual workflow inputs can become dangerous when they are inserted directly into:

- Shell commands
- Terraform variable values
- Resource names
- Deployment environments
- Docker tags
- File paths
- AWS account or role identifiers

This can create command injection, privilege-boundary bypass, or unintended deployment behavior.

## Preferred remediation

Remove inputs that can be derived safely from the branch or GitHub environment:

```yaml
on:
  workflow_dispatch:
```

Use trusted branch-to-environment mapping:

```yaml
- name: Resolve deployment environment
  id: environment
  shell: bash
  run: |
    case "${GITHUB_REF_NAME}" in
      dev) environment="dev" ;;
      uat) environment="uat" ;;
      production) environment="production" ;;
      *) echo "Unsupported branch" >&2; exit 1 ;;
    esac

    echo "environment=${environment}" >> "$GITHUB_OUTPUT"
```

## Alternative remediation when inputs are required

Use constrained `choice` inputs rather than unrestricted strings:

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: Deployment environment
        required: true
        type: choice
        options:
          - dev
          - uat
          - production
```

Then validate the value before use:

```yaml
- name: Validate environment
  shell: bash
  env:
    DEPLOY_ENV: ${{ inputs.environment }}
  run: |
    case "$DEPLOY_ENV" in
      dev|uat|production) ;;
      *) echo "Invalid environment" >&2; exit 1 ;;
    esac
```

Additional safeguards:

- Use GitHub Environments with required reviewers for production.
- Map AWS role ARNs through protected environment variables or secrets.
- Do not accept role ARN, account ID, command, path, or Terraform arguments as free-text input.
- Quote all shell variables.
- Give deployment workflows only the permissions they require.
- Pin third-party actions to verified commit SHAs.

---

# 4. Secret Scan Findings

## Raw result

```text
Failed secret checks: 37
```

The reported files are located under:

```text
/usr/local/lib/python3.11/site-packages/botocore/...
```

They include Botocore example files and paginator definitions containing strings that resemble:

- AWS access keys
- Base64 high-entropy values

No reported secret finding points to `/repo`.

## Assessment

These are likely **false positives from the Checkov runner environment**, not committed application secrets. Botocore contains sample API payloads that secret scanners can classify as credentials.

## Corrective action

Restrict the secrets scan to the checked-out repository:

```bash
checkov -d "${GITHUB_WORKSPACE}" --framework secrets
```

or:

```bash
cd "${GITHUB_WORKSPACE}"
checkov -d . --framework secrets
```

Do not scan `/`, `/usr/local`, the Python virtual environment, or globally installed packages.

After correcting the scan path, rerun the scan. Any remaining secret finding under the repository should be investigated immediately.

For a genuine exposed AWS credential:

1. Disable or delete the credential.
2. Create a replacement only if necessary.
3. Review CloudTrail for unauthorized use.
4. Remove the value from the current source file.
5. Purge it from Git history when it was committed.
6. Store secrets in GitHub Secrets, AWS Secrets Manager, or SSM Parameter Store.

---

# 5. Recommended Remediation Priority

## Priority 1 — Correct the scan scope

- Scan only the GitHub workspace.
- Exclude Checkov's Python installation and runner system directories.
- Rerun the secrets and Dockerfile scans.

Expected result: 37 secret alerts and two scanner-generated Dockerfile alerts should disappear.

## Priority 2 — Harden monitoring containers

For both Prometheus and Grafana:

- Pin the base image version or digest.
- Run as an explicit non-root user.
- Add a functioning health check.

## Priority 3 — Secure manual deployment workflows

- Remove unrestricted `workflow_dispatch` inputs.
- Prefer trusted branch and environment mappings.
- Use constrained choices and strict validation when inputs are necessary.
- Require approval for production through GitHub Environments.

## Priority 4 — Review Terraform suppressions

- Confirm the backend EC2 instance is private.
- Replace public frontend EC2 exposure with an ALB and HTTPS for production.
- Verify security-group attachments through a Terraform plan scan.
- Keep every suppression narrow, documented, and periodically reviewed.

---

# 6. Recommended Checkov Commands

## Complete repository scan

```bash
checkov -d . \
  --framework terraform,dockerfile,github_actions,secrets \
  --compact
```

## Terraform only

```bash
checkov -d terraform \
  --framework terraform \
  --compact
```

## Dockerfiles only

```bash
checkov -d . \
  --framework dockerfile \
  --compact
```

## GitHub Actions only

```bash
checkov -d .github/workflows \
  --framework github_actions \
  --compact
```

## Secret scan limited to repository

```bash
checkov -d . \
  --framework secrets \
  --compact
```

## Terraform plan scan

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
checkov -f tfplan.json --framework terraform_plan
```

## Generate CLI, JSON, and SARIF reports

```bash
mkdir -p checkov-reports

checkov -d . \
  --framework terraform,dockerfile,github_actions,secrets \
  --output cli \
  --output json \
  --output sarif \
  --output-file-path \
    console,checkov-reports/results_json.json,checkov-reports/results_sarif.sarif
```

---

# 7. GitHub Actions Example

```yaml
name: Checkov IaC Scan

on:
  pull_request:
    branches:
      - dev
      - uat
      - production
  push:
    branches:
      - dev
      - uat
      - production
  workflow_dispatch:

permissions:
  contents: read
  security-events: write

jobs:
  checkov:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Create report directory
        run: mkdir -p checkov-reports

      - name: Run Checkov
        uses: bridgecrewio/checkov-action@<VERIFIED_COMMIT_SHA>
        with:
          directory: .
          framework: terraform,dockerfile,github_actions,secrets
          output_format: cli,json,sarif
          output_file_path: console,checkov-reports/results_json.json,checkov-reports/results_sarif.sarif
          soft_fail: false

      - name: Upload Checkov reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: checkov-iac-report
          path: checkov-reports/
          retention-days: 30

      - name: Upload SARIF to GitHub Security
        if: always() && hashFiles('checkov-reports/results_sarif.sarif') != ''
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: checkov-reports/results_sarif.sarif
```

Pin Checkov and other third-party actions to verified full commit SHAs in production workflows.

---

# 8. Verification Checklist

After remediation, verify the following:

- [ ] Checkov scans only the repository workspace.
- [ ] No secret alerts reference `/usr/local/lib`, Botocore, or Checkov packages.
- [ ] Prometheus uses an approved pinned image.
- [ ] Grafana uses an approved pinned image.
- [ ] Both monitoring containers run as non-root.
- [ ] Both monitoring containers define working health checks.
- [ ] Manual deployment inputs are removed or strictly constrained.
- [ ] Production deployments require GitHub Environment approval.
- [ ] Backend EC2 has no public IP.
- [ ] Terraform suppressions have valid comments and owners.
- [ ] Terraform plan scanning confirms resource relationships.
- [ ] The rerun has no unreviewed failed checks.

---

# Final Assessment

The Terraform portion of the project passed all evaluated Checkov controls and is in good condition. The principal remediation work is limited to hardening the Prometheus and Grafana container definitions and tightening manual GitHub Actions inputs.

The reported secret failures do not currently indicate secrets committed to the application repository because every finding originated from the Checkov runner's installed Python packages. Correcting the scan scope is essential before using the secret count as a security gate.

**Recommended disposition:** Fix the six monitoring-container findings, review the two workflow-input findings, correct the scan scope, rerun Checkov, and retain the documented Terraform exceptions only where the architecture explicitly requires them.
