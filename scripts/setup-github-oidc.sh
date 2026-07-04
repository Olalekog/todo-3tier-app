#!/bin/bash
# AWS OIDC Provider Setup for GitHub Actions
# This script configures the necessary AWS IAM resources for GitHub Actions OIDC authentication

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Verify AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

print_info "AWS OIDC Provider Setup for GitHub Actions"
print_info "==========================================="
echo

# Get AWS Account ID
print_info "Retrieving AWS Account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$ACCOUNT_ID" ]; then
    print_error "Failed to retrieve AWS Account ID. Check your AWS credentials."
    exit 1
fi
print_info "AWS Account ID: $ACCOUNT_ID"
echo

# Input validation
read -p "Enter your GitHub organization name (or username for personal repos): " GITHUB_ORG
read -p "Enter your repository name (todo-3tier-app): " -i "todo-3tier-app" REPO_NAME
read -p "Enter AWS region [us-east-1]: " -i "us-east-1" AWS_REGION

if [ -z "$GITHUB_ORG" ] || [ -z "$REPO_NAME" ]; then
    print_error "GitHub organization and repository name are required."
    exit 1
fi

print_info "Configuration:"
print_info "  GitHub Org/User: $GITHUB_ORG"
print_info "  Repository: $REPO_NAME"
print_info "  AWS Region: $AWS_REGION"
print_info "  AWS Account: $ACCOUNT_ID"
echo

read -p "Continue with this configuration? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Setup cancelled."
    exit 0
fi

echo

# Step 1: Create OIDC Provider
print_info "Step 1: Creating GitHub OIDC Provider in AWS..."

PROVIDER_ARN=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[?contains(OpenIDConnectProviderArn, 'token.actions.githubusercontent.com')].OpenIDConnectProviderArn" --output text)

if [ -z "$PROVIDER_ARN" ]; then
    print_info "Creating new OIDC provider..."
    RESULT=$(aws iam create-open-id-connect-provider \
        --url https://token.actions.githubusercontent.com \
        --client-id-list sts.amazonaws.com \
        --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
        --region $AWS_REGION \
        --output json)
    PROVIDER_ARN=$(echo "$RESULT" | grep -o '"OpenIDConnectProviderArn": "[^"]*' | cut -d'"' -f4)
    print_info "Created OIDC provider: $PROVIDER_ARN"
else
    print_info "OIDC provider already exists: $PROVIDER_ARN"
fi
echo

# Step 2: Create Trust Policy
print_info "Step 2: Creating trust policy..."

TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${REPO_NAME}:*"
        }
      }
    }
  ]
}
EOF
)

print_info "Trust Policy prepared"
echo

# Step 3: Create IAM Role
print_info "Step 3: Creating IAM role (todo-3tier-github-oidc-role)..."

ROLE_NAME="todo-3tier-github-oidc-role"

# Check if role already exists
if aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
    print_warning "Role $ROLE_NAME already exists. Updating trust policy..."
    
    # Update the trust policy
    echo "$TRUST_POLICY" > /tmp/trust-policy.json
    aws iam update-assume-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-document file:///tmp/trust-policy.json
    
    ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)
    print_info "Updated trust policy for existing role: $ROLE_ARN"
else
    print_info "Creating new role..."
    
    echo "$TRUST_POLICY" > /tmp/trust-policy.json
    RESULT=$(aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/trust-policy.json \
        --output json)
    
    ROLE_ARN=$(echo "$RESULT" | grep -o '"Arn": "[^"]*' | head -1 | cut -d'"' -f4)
    print_info "Created role: $ROLE_ARN"
fi

rm -f /tmp/trust-policy.json
echo

# Step 4: Attach permissions policy
print_info "Step 4: Attaching permissions policy..."

POLICY_FILE="docs/github-actions-iam-policy.json"

if [ ! -f "$POLICY_FILE" ]; then
    print_error "Policy file not found: $POLICY_FILE"
    print_error "Please ensure you're running this script from the repository root."
    exit 1
fi

# Attach inline policy
aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name TerraformDeploymentPolicy \
    --policy-document file://$POLICY_FILE

print_info "Permissions policy attached successfully"
echo

# Step 5: Display summary and next steps
echo
print_info "Setup Complete!"
echo
print_info "Summary:"
print_info "  OIDC Provider ARN: $PROVIDER_ARN"
print_info "  Role Name: $ROLE_NAME"
print_info "  Role ARN: $ROLE_ARN"
echo

print_info "Next Steps:"
echo "1. Add the following GitHub Repository Variables:"
echo "   (Settings → Secrets and variables → Variables)"
echo
echo "   AWS_REGION: $AWS_REGION"
echo "   PROJECT_NAME: todo-3tier-simple"
echo "   BOOTSTRAP_ROLE_ARN: $ROLE_ARN"
echo "   TERRAFORM_VERSION: 1.9.0"
echo "   TF_STATE_BUCKET: <your-terraform-state-bucket-name>"
echo
echo "2. Add the following GitHub Repository Secret:"
echo "   (Settings → Secrets and variables → Secrets)"
echo
echo "   DB_PASSWORD: <your-strong-database-password>"
echo
echo "3. For production deployments (prod branch):"
echo "   Go to Settings → Environments → prod"
echo "   Enable 'Required reviewers' for approval gates"
echo "   Set 'Deployment branches' to allow 'uat' branch only"
echo
print_info "Documentation: See docs/github-oidc-setup.md for detailed instructions"
