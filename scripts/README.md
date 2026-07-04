# GitHub Actions OIDC Setup

This directory contains scripts to automate AWS IAM configuration for GitHub Actions.

## Quick Start

### Linux/macOS

```bash
chmod +x scripts/setup-github-oidc.sh
./scripts/setup-github-oidc.sh
```

### Windows (Git Bash or WSL)

```bash
bash scripts/setup-github-oidc.sh
```

## What the Script Does

1. **Creates GitHub OIDC Provider** - Registers GitHub's OIDC provider in AWS IAM (if not already present)
2. **Creates IAM Role** - Creates `todo-3tier-github-oidc-role` with proper trust relationships
3. **Attaches Permissions** - Applies the Terraform deployment policy from `docs/github-actions-iam-policy.json`
4. **Displays Configuration** - Outputs the role ARN and environment variables to configure in GitHub

## Prerequisites

- AWS CLI installed and configured with credentials that have IAM permissions
- Bash shell (Linux, macOS, or WSL)
- GitHub repository access to add variables and secrets

## Configuration After Running

After the script completes, you need to configure GitHub:

1. **Add Repository Variables** (Settings → Secrets and variables → Variables):
   - `AWS_REGION`: (displayed by script)
   - `PROJECT_NAME`: `todo-3tier-simple`
   - `BOOTSTRAP_ROLE_ARN`: (displayed by script)
   - `TERRAFORM_VERSION`: `1.9.0`
   - `TF_STATE_BUCKET`: Your S3 bucket for Terraform state

2. **Add Repository Secrets** (Settings → Secrets and variables → Secrets):
   - `DB_PASSWORD`: Strong database password

3. **For Production Environment** (Settings → Environments):
   - Create or edit `prod` environment
   - Enable required reviewers
   - Restrict deployment branch to `uat`

## Troubleshooting

If the script fails with "Not authorized", ensure:
- Your AWS credentials have IAM permissions
- You're in the correct AWS account
- The GitHub organization/repo names are correct

For detailed documentation, see [docs/github-oidc-setup.md](../docs/github-oidc-setup.md).
