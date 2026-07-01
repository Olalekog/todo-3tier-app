# Dockerized To-Do 3-Tier Application on AWS

This project deploys a simple Dockerized To-Do application on AWS using reusable Terraform modules and GitHub Actions.

The application uses **two separate single EC2 instances**:

- **Frontend EC2 instance** in a public subnet, running a React/Nginx Docker container
- **Backend EC2 instance** in a private subnet, running a FastAPI Docker container
- **RDS MySQL database** in private DB subnets

There is no ALB, no ASG, no Route 53, no ACM, no Cognito, and no app-created KMS key.

ECR is included because the frontend and backend are now packaged as Docker images and the EC2 instances need a private registry to pull those images.

---

## Architecture

```text
User Browser
   |
   | HTTP :80
   v
Public Subnet
Frontend EC2 Instance
Docker container: React static build served by Nginx
Nginx proxies /api requests
   |
   | Private traffic :8000
   v
Private App Subnet
Backend EC2 Instance
Docker container: FastAPI + Uvicorn
   |
   | Private traffic :3306
   v
Private DB Subnets
RDS MySQL
```

## Resource Design

| Tier | AWS Resource | Subnet Type | Internet Facing | Runtime |
|---|---|---|---|---|
| Frontend | Single EC2 instance | Public subnet | Yes | Docker container from ECR |
| Backend | Single EC2 instance | Private app subnet | No | Docker container from ECR |
| Database | RDS MySQL | Private DB subnets | No | Managed database |
| Image Registry | Amazon ECR | Regional service | No direct public access | Stores frontend/backend images |

The frontend and backend are **not deployed on the same server**. They are separate EC2 instances.

---

## Request Flow

```text
Browser
  -> Frontend EC2 Public IP :80
  -> Frontend Docker container: Nginx + React
  -> /api reverse proxy
  -> Backend EC2 Private IP :8000
  -> Backend Docker container: FastAPI
  -> RDS MySQL :3306
```

The backend EC2 does not have a public IP. The browser only reaches the public frontend EC2. Nginx inside the frontend Docker container proxies `/api` requests to the backend EC2 private IP.

---

## What Is Excluded

This simplified version intentionally does not deploy:

```text
No ALB
No ASG
No Route 53
No ACM
No app-created KMS key
No Cognito
No Kubernetes
```

This version **does use ECR** because Docker images need a registry for the EC2 instances to pull from.

The GitHub Actions workflow uses your existing S3 backend bucket for Terraform state. DynamoDB locking and KMS backend configuration are not used.

---

## Repository Structure

```text
.
├── .github
│   └── workflows
│       └── deploy.yml
├── backend
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── main.py
│   └── requirements.txt
├── frontend
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── index.html
│   ├── package.json
│   └── src
│       ├── App.jsx
│       └── style.css
├── terraform
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   ├── terraform.tfvars.example
│   ├── templates
│   │   ├── user_data_frontend.sh.tftpl
│   │   └── user_data_backend.sh.tftpl
│   └── modules
│       ├── network
│       ├── security-groups
│       ├── ecr
│       ├── compute
│       └── database
└── docs
    ├── architecture.md
    └── github-actions-iam-policy.json
```

---

## Terraform Modules

### `modules/network`

Creates:

```text
VPC
Public subnets
Private app subnets
Private DB subnets
Internet Gateway
NAT Gateway
Route tables
Route table associations
```

The NAT Gateway allows the private backend EC2 instance to pull Docker images from ECR and reach AWS APIs during bootstrapping.

### `modules/security-groups`

Creates:

```text
Frontend security group
Backend security group
Database security group
```

Traffic rules:

```text
Internet -> Frontend EC2 :80
Frontend EC2 -> Backend EC2 :8000
Backend EC2 -> RDS MySQL :3306
Optional SSH -> Frontend EC2 :22
```

### `modules/ecr`

Creates two ECR repositories:

```text
<project>/<environment>/todo-frontend
<project>/<environment>/todo-backend
```

Example:

```text
todo-3tier-simple/dev/todo-frontend
todo-3tier-simple/dev/todo-backend
```

### `modules/compute`

Creates exactly two EC2 instances:

```text
aws_instance.frontend
aws_instance.backend
```

Also creates an EC2 IAM role and instance profile with ECR read-only access so both EC2 instances can pull Docker images from ECR.

### `modules/database`

Creates:

```text
RDS MySQL DB subnet group
RDS MySQL single database instance
```

---

## Docker Images

### Frontend image

The frontend Docker image uses a multi-stage build:

```text
Node image builds React app
Nginx image serves static React files
```

The frontend EC2 starts the image and mounts a generated Nginx config that proxies `/api` to the private backend EC2 IP.

### Backend image

The backend Docker image runs:

```text
FastAPI + Uvicorn
```

The backend container receives database connection values through Docker environment variables from EC2 user data.

---

## Database Initialization

FastAPI initializes the database automatically on startup.

It creates this table if it does not already exist:

```sql
CREATE TABLE IF NOT EXISTS todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

It also creates one test To-Do item automatically:

```text
Test To-Do item created during application initialization
```

The seed is idempotent, so it does not duplicate every time the backend restarts.

---

## GitHub Actions Deployment

Workflow file:

```text
.github/workflows/deploy.yml
```

The workflow uses GitHub OIDC to assume your existing AWS role:

```text
arn:aws:iam::866934333672:role/react-js-application-github-actions-bootstrap-role
```

The deployment flow is:

```text
1. terraform init using S3-only backend
2. terraform validate
3. terraform apply -target=module.ecr to create ECR repositories first
4. docker build frontend image
5. docker build backend image
6. docker push both images to ECR with latest and Git SHA tags
7. terraform apply full stack
8. EC2 user data pulls the images and runs the containers
```

The workflow pushes these image tags:

```text
latest
<git-sha>
```

Terraform deploys the `latest` tag by default.

---

## Required GitHub Repository Variables

Add these under:

```text
GitHub Repo -> Settings -> Secrets and variables -> Actions -> Variables
```

```text
AWS_REGION=us-east-1
PROJECT_NAME=todo-3tier-simple
ENVIRONMENT=dev
BOOTSTRAP_ROLE_ARN=arn:aws:iam::866934333672:role/react-js-application-github-actions-bootstrap-role
TERRAFORM_VERSION=1.9.0
TF_STATE_BUCKET=react-js-application-terraform-state-866934333672
ALLOWED_SSH_CIDR=<your-public-ip>/32
```

## Required GitHub Secret

Add this under:

```text
GitHub Repo -> Settings -> Secrets and variables -> Actions -> Secrets
```

```text
DB_PASSWORD=<strong-rds-password>
```

---

## S3-Only Terraform Backend

Terraform backend uses your existing S3 bucket only:

```bash
terraform init \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="key=${PROJECT_NAME}/${ENVIRONMENT}/terraform.tfstate" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="encrypt=true"
```

Removed from this package:

```text
TF_LOCK_TABLE
TF_STATE_KMS_KEY_ARN
TF_STATE_KMS_KEY_ID
DynamoDB backend locking
KMS backend config
```

---

## Local Docker Build Test

Frontend:

```bash
docker build -t todo-frontend:local ./frontend
```

Backend:

```bash
docker build -t todo-backend:local ./backend
```

---

## Local Terraform Commands

```bash
cd terraform
terraform fmt -recursive
terraform init \
  -backend-config="bucket=react-js-application-terraform-state-866934333672" \
  -backend-config="key=todo-3tier-simple/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true"
terraform validate
terraform apply -target=module.ecr -auto-approve
```

Then build and push Docker images to the ECR URLs from Terraform output, and run:

```bash
terraform apply -auto-approve
```

---

## Test the Application

After deployment, get the frontend URL from Terraform output:

```bash
terraform output frontend_url
```

Open it in the browser, or test with curl:

```bash
curl http://<frontend-public-ip>/api/todos
```

Create another test record:

```bash
curl -X POST http://<frontend-public-ip>/api/seed
```

---

## Important Notes

- The frontend and backend are deployed on separate EC2 instances.
- The frontend EC2 has a public IP.
- The backend EC2 has no public IP.
- RDS is not publicly accessible.
- The frontend Docker container runs Nginx and serves React.
- Nginx proxies API traffic to the backend EC2 private IP.
- The backend Docker container runs FastAPI.
- This is a simplified learning/demo deployment, not a highly available production architecture.
