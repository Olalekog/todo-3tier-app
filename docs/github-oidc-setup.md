# GitHub Actions OIDC Setup for AWS

This document explains how to configure AWS IAM to trust GitHub's OIDC provider for secure, keyless authentication in GitHub Actions workflows.

## Prerequisites

- AWS Account with IAM permissions
- GitHub organization or personal repository
- AWS CLI configured locally

## Step 1: Add GitHub OIDC Provider to AWS IAM

Run these commands to add the GitHub OIDC provider to your AWS account:

```bash
# Create the OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --region us-east-1
```

**Output Example:**
```
{
    "OpenIDConnectProviderArn": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
}
```

Note the ARN from the output - you'll need it in the next step.

## Step 2: Create the Bootstrap IAM Role with OIDC Trust

Create a new IAM role with a trust policy that allows GitHub to assume it:

### Via AWS CLI

```bash
# Replace with your values:
# YOUR_ACCOUNT_ID: Your AWS Account ID
# YOUR_GITHUB_ORG: Your GitHub organization (use * for any org if personal repo)
# YOUR_REPO: Your repository name (use * for any repo)

cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
EOF

# Create the role
aws iam create-role \
  --role-name todo-3tier-github-oidc-role \
  --assume-role-policy-document file://trust-policy.json
```

### Via AWS Console

1. Go to **IAM** → **Roles** → **Create role**
2. Select **Web identity** as the trusted entity type
3. Choose **token.actions.githubusercontent.com** from the provider list
4. Set **Audience** to `sts.amazonaws.com`
5. Click **Next**
6. Add the permissions policy (see Step 3)
7. Name the role: `todo-3tier-github-oidc-role`
8. Review the trust policy matches the one above

## Step 3: Attach the Permissions Policy

The role needs permissions to:
- Access Terraform S3 backend
- Manage ECR repositories
- Manage EC2, RDS, VPC resources
- Manage IAM roles for EC2 instances

Attach the policy from `docs/github-actions-iam-policy.json`:

```bash
aws iam put-role-policy \
  --role-name todo-3tier-github-oidc-role \
  --policy-name TerraformDeploymentPolicy \
  --policy-document file://github-actions-iam-policy.json
```

## Step 4: Configure GitHub Repository Variables

Add these as **Repository Variables** (not secrets) in GitHub:

1. Go to **Settings** → **Secrets and variables** → **Variables**
2. Add:
   - `AWS_REGION`: `us-east-1`
   - `PROJECT_NAME`: `todo-3tier-simple`
   - `TF_STATE_BUCKET`: `<your-terraform-state-bucket>`
   - `TERRAFORM_VERSION`: `1.9.0`
   - `BOOTSTRAP_ROLE_ARN`: `arn:aws:iam::YOUR_ACCOUNT_ID:role/todo-3tier-github-oidc-role`

3. Go to **Settings** → **Secrets and variables** → **Secrets**
4. Add:
   - `DB_PASSWORD`: Your strong database password

## Step 5: Configure GitHub Environments (for Production)

For production deployments with approval gates:

1. Go to **Settings** → **Environments**
2. Create/edit the `prod` environment
3. Enable **Required reviewers** and add team members
4. Set **Deployment branches** to `uat` only

## Troubleshooting

### Error: "Not authorized to perform sts:AssumeRoleWithWebIdentity"

**Cause**: The role's trust policy doesn't allow GitHub to assume it.

**Solutions**:
1. Verify the OIDC provider ARN is correct in the trust policy
2. Verify the GitHub org and repo names in the `sub` condition match your setup
3. Ensure the `aud` (audience) is set to `sts.amazonaws.com`
4. Check the thumbprint is correct: `6938fd4d98bab03faadb97b34396831e3780aea1`

```bash
# List the trust policy to verify
aws iam get-role --role-name todo-3tier-github-oidc-role
```

### Error: "Repository secret OIDC token request was denied"

**Cause**: The GitHub OIDC provider isn't properly configured in AWS.

**Solution**: Re-run Step 1 to add the OIDC provider, then verify:

```bash
# List OIDC providers
aws iam list-open-id-connect-providers
```

### Workflow hangs or times out during "Assuming role with OIDC"

**Cause**: GitHub Actions runners are using Node 20, which is deprecated.

**Solution**: Add this to your workflow `env` section:

```yaml
env:
  ACTIONS_ALLOW_USE_UNSECURE_NODE_VERSION: true
```

Or update to Node 24-compatible actions (recommended).

## Verification

After setup, run a test deployment:

```bash
# Trigger workflow manually or push to dev branch
gh workflow run deploy.yml -f environment=dev -f terraform_action=plan
```

Check the logs in GitHub Actions for successful OIDC authentication:
```
Run aws-actions/configure-aws-credentials@v4
Assuming role with OIDC
...
AWS_ACCOUNT_ID=123456789
AWS_ROLE_ARN=arn:aws:iam::123456789:role/todo-3tier-github-oidc-role
...
```

## References

- [GitHub Actions AWS OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS OIDC Provider Setup](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html)
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
