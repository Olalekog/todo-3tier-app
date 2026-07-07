# React JS Application – 3-Tier AWS Deployment

## Project Overview

This repository deploys a Dockerized 3-tier To-Do application on AWS using Terraform and GitHub Actions.

The application is composed of:

| Tier | Technology | AWS Placement |
|---|---|---|
| Frontend | React + Nginx container | Public EC2 instance |
| Backend | FastAPI container | Private EC2 instance |
| Database | MySQL | Amazon RDS in private DB subnets |

The infrastructure is provisioned with Terraform, Docker images are stored in Amazon ECR, and CI/CD is handled with GitHub Actions using AWS OIDC authentication.

---


## AWS Solution Diagram

The diagram below shows the end-to-end AWS solution architecture for the 3-tier To-Do application, including the public frontend tier, private backend tier, private RDS database tier, Amazon ECR image registry, S3 Terraform state backend, GitHub Actions, OIDC IAM role, and Terraform provisioning flow.

![AWS Solution Diagram – 3-Tier To-Do Application](assets/aws_3_tier_to_do_app_architecture.png)

### Diagram Summary

```text
User Browser
    ↓ HTTP/HTTPS
Internet Gateway
    ↓
Frontend EC2 in Public Subnet
    ↓ API :8000
Backend EC2 in Private App Subnet
    ↓ MySQL :3306
RDS MySQL in Private DB Subnet
```

Supporting services:

```text
GitHub Actions → OIDC IAM Role → Terraform → AWS Resources
Terraform remote state → S3 Bucket
Docker images → Amazon ECR
Frontend EC2 pulls frontend image from ECR
Backend EC2 pulls backend image from ECR
```


## Current Project Name

```text
react-js-application
```

The ECR repositories use this naming pattern:

```text
react-js-application/<environment>/todo-frontend
react-js-application/<environment>/todo-backend
```

Example for dev:

```text
866934333672.dkr.ecr.us-east-1.amazonaws.com/react-js-application/dev/todo-frontend:latest
866934333672.dkr.ecr.us-east-1.amazonaws.com/react-js-application/dev/todo-backend:latest
```


---

## Repository Structure

```text
repo-root/
├── .github/
│   └── workflows/
│       ├── docker-build-push.yml
│       ├── deploy.yml
│       └── destroy.yml
├── frontend/
│   ├── Dockerfile
│   └── ...
├── backend/
│   ├── Dockerfile
│   └── ...
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── moved.tf
│   ├── versions.tf
│   ├── environments/
│   │   ├── dev.tfvars
│   │   ├── uat.tfvars
│   │   └── prod.tfvars
│   ├── modules/
│   │   ├── network/
│   │   ├── security-tools/
│   │   ├── ecr/
│   │   ├── database/
│   │   └── compute/
│   └── templates/
│       ├── user_data_frontend.sh.tftpl
│       └── user_data_backend.sh.tftpl
├── assets/
│   └── aws_3_tier_to_do_app_architecture.png
├── README.md
└── .gitignore
```

---

## AWS Services Used

| AWS Service | Purpose |
|---|---|
| VPC | Isolated network for the application |
| Public Subnets | Host the frontend EC2 instance |
| Private App Subnets | Host the backend EC2 instance |
| Private DB Subnets | Host the RDS database |
| Internet Gateway | Allows public internet access for frontend |
| Route Tables | Controls traffic routing between subnets |
| Security Groups | Controls inbound/outbound traffic |
| EC2 | Runs Docker containers for frontend and backend |
| IAM Role / Instance Profile | Allows EC2 to pull Docker images from ECR |
| ECR | Stores frontend and backend Docker images |
| RDS MySQL | Stores application data |
| S3 Backend | Stores Terraform remote state |
| GitHub Actions OIDC | Allows GitHub Actions to assume AWS IAM role securely |

---

## High-Level Architecture Diagram

```mermaid
flowchart TB
    User[User Browser] -->|HTTP :80| FrontendEC2[Frontend EC2<br/>Public Subnet<br/>React + Nginx Container]

    FrontendEC2 -->|API Requests :8000| BackendEC2[Backend EC2<br/>Private App Subnet<br/>FastAPI Container]

    BackendEC2 -->|MySQL :3306| RDS[(Amazon RDS MySQL<br/>Private DB Subnets)]

    FrontendEC2 -->|Pull Image| ECRFrontend[(ECR Frontend Repository)]
    BackendEC2 -->|Pull Image| ECRBackend[(ECR Backend Repository)]

    GitHub[GitHub Actions] -->|OIDC Assume Role| IAMRole[AWS IAM Role]
    IAMRole --> Terraform[Terraform Deploy]
    Terraform --> VPC[AWS VPC Infrastructure]
    Terraform --> FrontendEC2
    Terraform --> BackendEC2
    Terraform --> RDS
    Terraform --> ECRFrontend
    Terraform --> ECRBackend
```

---

## AWS Network Architecture Diagram

```mermaid
flowchart TB
    subgraph AWS[AWS Account: 866934333672]
        subgraph VPC[VPC: react-js-application]
            IGW[Internet Gateway]

            subgraph PublicSubnet[Public Subnet]
                Frontend[Frontend EC2<br/>Docker: React/Nginx<br/>Port 80]
            end

            subgraph PrivateAppSubnet[Private App Subnet]
                Backend[Backend EC2<br/>Docker: FastAPI<br/>Port 8000]
            end

            subgraph PrivateDBSubnet[Private DB Subnets]
                DB[(RDS MySQL<br/>Port 3306)]
            end

            FrontendSG[Frontend Security Group]
            BackendSG[Backend Security Group]
            DatabaseSG[Database Security Group]
        end

        ECR[(Amazon ECR)]
        S3[(S3 Terraform State Bucket)]
        IAM[GitHub OIDC IAM Role]
    end

    Internet[Internet Users] --> IGW
    IGW --> Frontend
    FrontendSG --> Frontend

    Frontend --> Backend
    BackendSG --> Backend

    Backend --> DB
    DatabaseSG --> DB

    Frontend --> ECR
    Backend --> ECR

    Terraform[GitHub Actions + Terraform] --> IAM
    Terraform --> S3
    Terraform --> VPC
```

---

## Application Request Flow

```mermaid
sequenceDiagram
    participant User as User Browser
    participant FE as Frontend EC2 / Nginx
    participant BE as Backend EC2 / FastAPI
    participant DB as RDS MySQL

    User->>FE: Open frontend URL over HTTP
    FE-->>User: Serve React static files
    User->>FE: Create / read / update / delete To-Do item
    FE->>BE: Proxy API request to backend on port 8000
    BE->>DB: Query or update MySQL data
    DB-->>BE: Return database response
    BE-->>FE: Return API response
    FE-->>User: Display updated To-Do list
```

---

## CI/CD Flow

The project uses separate workflows for image build, deployment, and destroy.

| Workflow | Purpose |
|---|---|
| `docker-build-push.yml` | Builds, tests, and pushes Docker images to ECR |
| `deploy.yml` | Runs Terraform plan/apply for infrastructure and image updates |
| `destroy.yml` | Runs Terraform destroy manually with confirmation |

---

## Docker Build/Test/Push Flow

```mermaid
flowchart TD
    Push[Push to dev / uat / prod] --> Detect[Detect changed files]

    Detect -->|frontend/** changed| BuildFrontend[Build Frontend Image]
    Detect -->|backend/** changed| BuildBackend[Build Backend Image]
    Detect -->|terraform/** only| SkipDocker[Skip Docker Build]

    BuildFrontend --> TestFrontend[Test Frontend Container]
    BuildBackend --> TestBackend[Test Backend Container with MySQL]

    TestFrontend --> PushFrontend[Push Frontend Image to ECR<br/>SHA tag + latest tag]
    TestBackend --> PushBackend[Push Backend Image to ECR<br/>SHA tag + latest tag]

    PushFrontend --> DeployFrontend[Trigger Dev Deploy<br/>frontend workload only]
    PushBackend --> DeployBackend[Trigger Dev Deploy<br/>backend workload only]

    SkipDocker --> DeployInfra[Trigger Terraform Deploy<br/>infra only]
```

---

## Workload-Specific Image Deployment

The deployment is designed so frontend and backend updates are isolated.

### Frontend Change

```text
frontend/** changes
```

Result:

```text
Build frontend image only
Push frontend image with SHA and latest tags
Deploy only module.frontend_compute
Backend infrastructure is not modified
```

### Backend Change

```text
backend/** changes
```

Result:

```text
Build backend image only
Push backend image with SHA and latest tags
Deploy only module.backend_compute
Frontend infrastructure is not modified
```

### Infrastructure Change

```text
terraform/** changes
```

Result:

```text
Skip Docker image build
Run Terraform infrastructure plan/apply
Use existing image tags
```

---

## Terraform Architecture

The root Terraform module separates backend and frontend compute workloads using the same reusable compute module.

```hcl
module "backend_compute" {
  source = "./modules/compute"

  workload_name               = "backend"
  instance_type               = var.backend_instance_type
  subnet_id                   = module.network.private_app_subnet_ids[0]
  security_group_id           = module.security_groups.backend_security_group_id
  associate_public_ip_address = false
  image_uri                   = local.backend_image_uri
  user_data_template_path     = "${path.module}/templates/user_data_backend.sh.tftpl"
}

module "frontend_compute" {
  source = "./modules/compute"

  workload_name               = "frontend"
  instance_type               = var.frontend_instance_type
  subnet_id                   = module.network.public_subnet_ids[0]
  security_group_id           = module.security_groups.frontend_security_group_id
  associate_public_ip_address = true
  image_uri                   = local.frontend_image_uri
  user_data_template_path     = "${path.module}/templates/user_data_frontend.sh.tftpl"
}
```

---

## Terraform Module Diagram

```mermaid
flowchart TB
    Root[terraform/main.tf]

    Root --> Network[modules/network]
    Root --> SG[modules/security-tools]
    Root --> ECR[modules/ecr]
    Root --> DB[modules/database]
    Root --> BackendCompute[module backend_compute<br/>source: modules/compute]
    Root --> FrontendCompute[module frontend_compute<br/>source: modules/compute]

    Network --> VPC[VPC, Subnets, Route Tables, IGW]
    SG --> SecurityGroups[Frontend, Backend, Database Security Groups]
    ECR --> ECRRepos[Frontend and Backend ECR Repositories]
    DB --> RDS[RDS MySQL]
    BackendCompute --> BackendEC2[Backend EC2 Instance]
    FrontendCompute --> FrontendEC2[Frontend EC2 Instance]
```

---

## Terraform Variables

Key variables:

```hcl
project_name = "react-js-application"
environment  = "dev"
aws_region   = "us-east-1"

frontend_instance_type = "t3.micro"
backend_instance_type  = "t3.micro"

frontend_image_tag = "latest"
backend_image_tag  = "latest"
```

---

## Environment Defaults

| Environment | Frontend Instance | Backend Instance | DB Instance |
|---|---:|---:|---:|
| dev | `t3.micro` | `t3.micro` | `db.t3.micro` |
| uat | `t3.micro` | `t3.small` | `db.t3.micro` |
| prod | `t3.small` | `t3.medium` | `db.t3.small` |

---

## Terraform State Backend

The project uses an S3 backend for Terraform state.

Example state key:

```text
react-js-application/dev/terraform.tfstate
```

Terraform init example:

```bash
terraform init \
  -backend-config="bucket=react-js-application-terraform-state-866934333672" \
  -backend-config="key=react-js-application/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true"
```

---

## GitHub Repository Variables

Configure these under:

```text
GitHub Repository → Settings → Secrets and variables → Actions → Variables
```

| Variable | Example |
|---|---|
| `AWS_REGION` | `us-east-1` |
| `AWS_ACCOUNT_ID` | `866934333672` |
| `PROJECT_NAME` | `react-js-application` |
| `BOOTSTRAP_ROLE_ARN` | `arn:aws:iam::866934333672:role/Reactjs-application-role` |
| `TF_STATE_BUCKET` | `react-js-application-terraform-state-866934333672` |
| `TERRAFORM_VERSION` | `1.9.0` |

---

## GitHub Repository Secrets

Configure these under:

```text
GitHub Repository → Settings → Secrets and variables → Actions → Secrets
```

| Secret | Purpose |
|---|---|
| `DB_PASSWORD` | RDS MySQL password used by Terraform and backend container |

---

## GitHub OIDC Trust Policy

The GitHub Actions role must trust your repo.

Example current-repo wildcard trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCurrentRepoGitHubActionsOIDC",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::866934333672:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:Olalekog/todo-3tier-app:*"
        }
      }
    }
  ]
}
```

If your repo is named `react-js-application`, use:

```text
repo:Olalekog/react-js-application:*
```

---

## Security Group Flow

```mermaid
flowchart LR
    Internet[Internet] -->|HTTP 80| FrontendSG[Frontend Security Group]
    Admin[Your IP] -->|SSH 22| FrontendSG

    FrontendSG -->|TCP 8000| BackendSG[Backend Security Group]
    PrivateAppCIDR[Private App Subnet CIDRs] -->|TCP 8000| BackendSG

    BackendSG -->|TCP 3306| DatabaseSG[Database Security Group]
```

---

## Deployment Flow

```mermaid
flowchart TD
    DevBranch[Push to dev] --> DockerWorkflow[Docker Build Test Push]

    DockerWorkflow --> ChangeDetect[Detect changed workload]

    ChangeDetect -->|Frontend| FrontendPipeline[Build/Test/Push Frontend]
    ChangeDetect -->|Backend| BackendPipeline[Build/Test/Push Backend]
    ChangeDetect -->|Infra Only| InfraPipeline[Skip Docker Build]

    FrontendPipeline --> DeployWorkflow[Deploy Workflow]
    BackendPipeline --> DeployWorkflow
    InfraPipeline --> DeployWorkflow

    DeployWorkflow --> TerraformInit[Terraform Init]
    TerraformInit --> ImportECR[Import ECR Repos if Already Existing]
    ImportECR --> TerraformPlan[Terraform Plan]
    TerraformPlan --> PlanCheck[Check Plan JSON]

    PlanCheck -->|No Changes| SkipApply[Skip Apply]
    PlanCheck -->|Safe In-Place Changes| TerraformApply[Terraform Apply]
    PlanCheck -->|Destroy/Replace Detected| Block[Block Unless allow_replacement=true]

    TerraformApply --> Outputs[Terraform Outputs]
```

---

## Destroy Flow

Destroy is handled by a separate workflow:

```text
.github/workflows/destroy.yml
```

Run manually from GitHub Actions:

```text
Actions → Destroy Infrastructure → Run workflow
```

Inputs:

```text
environment: dev
confirm_destroy: DESTROY
image_tag: latest
frontend_image_tag: latest
backend_image_tag: latest
```

Destroy workflow flow:

```mermaid
flowchart TD
    Manual[Manual Workflow Dispatch] --> Confirm[Validate confirm_destroy == DESTROY]
    Confirm --> OIDC[Assume AWS Role with OIDC]
    OIDC --> Init[Terraform Init]
    Init --> PlanDestroy[Terraform Plan Destroy]
    PlanDestroy --> ApplyDestroy[Terraform Apply Destroy]
    ApplyDestroy --> Deleted[Resources Deleted]
```

---

## Deployment Commands

### Terraform Init

```bash
cd terraform

terraform init \
  -backend-config="bucket=react-js-application-terraform-state-866934333672" \
  -backend-config="key=react-js-application/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true"
```

### Terraform Plan

```bash
terraform plan \
  -var-file="environments/dev.tfvars" \
  -var="aws_region=us-east-1" \
  -var="project_name=react-js-application" \
  -var="db_password=$DB_PASSWORD" \
  -var="frontend_image_tag=latest" \
  -var="backend_image_tag=latest"
```

### Terraform Apply

```bash
terraform apply -auto-approve
```

### Terraform Destroy

```bash
terraform destroy \
  -var-file="environments/dev.tfvars" \
  -var="aws_region=us-east-1" \
  -var="project_name=react-js-application" \
  -var="db_password=$DB_PASSWORD" \
  -var="frontend_image_tag=latest" \
  -var="backend_image_tag=latest" \
  -auto-approve
```

---

## ECR Image Validation

Check frontend tags:

```bash
aws ecr describe-images \
  --region us-east-1 \
  --repository-name react-js-application/dev/todo-frontend \
  --query "imageDetails[*].imageTags" \
  --output table
```

Check backend tags:

```bash
aws ecr describe-images \
  --region us-east-1 \
  --repository-name react-js-application/dev/todo-backend \
  --query "imageDetails[*].imageTags" \
  --output table
```

Expected tags:

```text
latest
<commit-sha>
```

---

## Manual Frontend Container Recovery

If frontend user data failed because the image tag was missing, SSH to the frontend EC2 instance and run:

```bash
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID="866934333672"

aws ecr get-login-password --region "$AWS_REGION" | \
sudo docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

sudo docker pull 866934333672.dkr.ecr.us-east-1.amazonaws.com/react-js-application/dev/todo-frontend:latest

sudo docker rm -f todo-frontend 2>/dev/null || true

sudo docker run -d \
  --name todo-frontend \
  --restart unless-stopped \
  -p 80:80 \
  866934333672.dkr.ecr.us-east-1.amazonaws.com/react-js-application/dev/todo-frontend:latest

sudo docker ps
curl -I http://localhost
```

---

## Manual Backend Container Recovery

SSH into the backend EC2 instance and run:

```bash
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID="866934333672"

aws ecr get-login-password --region "$AWS_REGION" | \
sudo docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

sudo docker pull 866934333672.dkr.ecr.us-east-1.amazonaws.com/react-js-application/dev/todo-backend:latest

sudo docker rm -f todo-backend 2>/dev/null || true

sudo docker run -d \
  --name todo-backend \
  --restart unless-stopped \
  -p 8000:8000 \
  -e DB_HOST="<RDS_ENDPOINT>" \
  -e DB_PORT="3306" \
  -e DB_NAME="todoapp" \
  -e DB_USER="todo_admin" \
  -e DB_PASSWORD="<DB_PASSWORD>" \
  866934333672.dkr.ecr.us-east-1.amazonaws.com/react-js-application/dev/todo-backend:latest
```

---

## Troubleshooting

### Frontend EC2 has no containers

Check Docker:

```bash
sudo systemctl status docker --no-pager
sudo docker ps -a
```

Check user data logs:

```bash
sudo tail -n 200 /var/log/cloud-init-output.log
```

Search common errors:

```bash
sudo grep -i "error\|failed\|denied\|unable\|ecr\|docker" /var/log/cloud-init-output.log
```

---

### ECR image latest tag not found

Error:

```text
failed to resolve reference "...todo-frontend:latest": not found
```

Fix:

```bash
aws ecr describe-images \
  --region us-east-1 \
  --repository-name react-js-application/dev/todo-frontend \
  --query "imageDetails[*].imageTags" \
  --output table
```

Then run the Docker workflow manually for the missing workload or retag an existing SHA image as `latest`.

---

### Backend cannot connect to RDS

From backend EC2:

```bash
nc -vz <RDS_ENDPOINT> 3306
```

Check backend logs:

```bash
sudo docker logs todo-backend --tail 100
```

Confirm backend security group allows outbound to RDS and database security group allows inbound from backend security group on port `3306`.

---

### HTTP 408 from frontend

Check frontend container:

```bash
sudo docker ps -a
sudo docker logs todo-frontend --tail 100
```

Check if frontend can reach backend:

```bash
curl -v http://<BACKEND_PRIVATE_IP>:8000/health
```

Check backend:

```bash
sudo docker ps -a
sudo docker logs todo-backend --tail 100
curl -v http://localhost:8000/health
```

---

### VPC dependency violation during destroy

Find ENIs:

```bash
aws ec2 describe-network-interfaces \
  --region us-east-1 \
  --filters Name=vpc-id,Values=<VPC_ID> \
  --query "NetworkInterfaces[*].{ENI:NetworkInterfaceId,Status:Status,Description:Description,RequesterManaged:RequesterManaged,Subnet:SubnetId}" \
  --output table
```

If description is:

```text
RDSNetworkInterface
```

Delete the RDS instance first, then rerun destroy.

---

## Best Practices Used

| Area | Practice |
|---|---|
| Authentication | GitHub OIDC instead of static AWS keys |
| Terraform state | Remote S3 backend |
| Network isolation | Backend and database in private subnets |
| Image deployment | ECR with SHA and latest tags |
| Change isolation | Frontend image updates target frontend compute only |
| Safety | Destructive Terraform actions blocked unless explicitly confirmed |
| Destroy | Separate manual destroy workflow with confirmation |
| Reusability | Single compute module reused for frontend and backend |

---

## Final Deployment Checklist

Before deploying, confirm:

```text
GitHub variables are configured
GitHub secret DB_PASSWORD exists
OIDC trust policy allows the repo
Terraform state bucket exists
dev.tfvars / uat.tfvars / prod.tfvars are valid assignment files
ECR repositories exist or deploy workflow can import/create them
Docker workflow pushes both SHA and latest tags
Frontend and backend security groups allow required traffic
```

Then deploy:

```text
Push frontend/backend/terraform changes to dev
Docker workflow builds and pushes images
Deploy workflow applies infrastructure
Frontend URL is returned in Terraform outputs
```

---

## Expected Outputs

Terraform outputs should include:

```text
frontend_public_ip
frontend_url
backend_private_ip
database_endpoint
frontend_ecr_repository_url
backend_ecr_repository_url
```

Open the frontend in your browser:

```text
http://<frontend_public_ip>
```

---

# Supplemental Project Notes

## Excluded by Design

This simplified version does **not** use:

- ALB; frontend and backend run directly on EC2 instances
- Frontend and SonarQube are intentionally internet-facing
- CKV_AWS_88 is skipped for the shared EC2 module because those public-facing workloads are intentional
- ASG
- Route 53
- ACM
- Cognito
- Application-created KMS key
- DynamoDB state locking

---

## Diagram Flow Overview

This repository includes three diagram assets in the `assets/` folder. These diagrams are referenced directly in this README and can also be opened separately from GitHub.

| Diagram | File | What It Shows |
|---|---|---|
| Architecture diagram | `assets/architecture-diagram.svg` | AWS 3-tier layout with public frontend EC2, private backend EC2, private RDS, ECR, S3 state, and GitHub Actions |
| Deployment flow | `assets/deployment-flow.svg` | CI/CD path from GitHub push through dev validate, build, test, and deploy |
| Request flow | `assets/request-flow.svg` | Browser request path through frontend Nginx proxy, FastAPI backend, and RDS MySQL |
| Promotion flow | `assets/promotion-flow.svg` | Branch promotion guard: only `dev → uat`, then `uat → prod` with production approval gate |

### Architecture Diagram Flow

```text
GitHub Actions
  -> Assumes AWS OIDC IAM role
  -> Builds Docker images
  -> Pushes images to Amazon ECR
  -> Runs Terraform using S3 remote state
  -> Creates VPC, subnets, security groups, EC2, ECR, and RDS

User Browser
  -> Public Frontend EC2 :80
  -> React app served by Nginx
  -> /api traffic proxied to private Backend EC2 :8000
  -> FastAPI reads/writes To-Do data
  -> RDS MySQL :3306
```

![Architecture Diagram](assets/architecture-diagram.svg)

### Deployment Pipeline Flow

```text
Developer pushes to dev branch
  -> GitHub Actions starts
  -> Dev Validate
      -> Check required variables
      -> Configure AWS OIDC credentials
      -> Terraform fmt/init/validate
  -> Dev Build
      -> Ensure ECR repositories exist
      -> Build frontend Docker image
      -> Build backend Docker image
      -> Push latest and Git SHA image tags
  -> Dev Test
      -> Login to ECR again because this is a new runner
      -> Pull pushed images
      -> Run frontend container locally
      -> Run temporary MySQL test container
      -> Run backend container locally
      -> Test frontend and backend health endpoints
  -> Dev Deploy
      -> Terraform plan/apply
      -> EC2 instances pull Docker images
      -> Backend initializes database
      -> Frontend serves the To-Do UI
```

![Deployment Flow](assets/deployment-flow.svg)

### Application Request Flow

```text
1. User opens http://<frontend-public-ip>
2. Frontend EC2 receives HTTP request on port 80
3. Nginx serves React static files
4. React calls /api/todos
5. Nginx proxies /api traffic to backend private IP on port 8000
6. FastAPI handles the request
7. FastAPI connects to RDS MySQL on port 3306
8. RDS returns To-Do data
9. FastAPI returns JSON response
10. React updates the browser UI
```

![Request Flow](assets/request-flow.svg)


### Environment Promotion Flow

The workflow enforces controlled promotion between environments. Pull requests are allowed only in this order:

```text
dev branch
  -> Pull request into uat
  -> Merge to uat deploys the UAT environment
  -> Pull request from uat into prod
  -> Merge to prod waits for GitHub Environment approval
  -> Approved prod deployment runs Terraform with prod.tfvars
```

Invalid promotion paths are blocked by the `validate-promotion-path` job. Examples of blocked paths:

```text
feature -> uat
feature -> prod
dev -> prod
prod -> uat
```

![Promotion Flow](assets/promotion-flow.svg)

---

## Environment Promotion Rules

The pipeline supports three environments with separate tfvars files:

| Branch | Terraform tfvars file | Deployment behavior | Approval requirement |
|---|---|---|---|
| `dev` | `terraform/environments/dev.tfvars` | Push to `dev` builds, tests, and deploys dev | No approval by default |
| `uat` | `terraform/environments/uat.tfvars` | Only PRs from `dev` are allowed; merge deploys UAT | Optional GitHub Environment approval |
| `prod` | `terraform/environments/prod.tfvars` | Only PRs from `uat` are allowed; merge waits for production approval | Required GitHub Environment approval |

### Pull request promotion guard

The workflow has a `validate-promotion-path` job that runs on pull requests into `uat` and `prod`. It allows only:

```text
dev -> uat
uat -> prod
```

Any other pull request path fails immediately before Terraform validation or deployment.

### Production approval gate

The deploy job uses:

```yaml
environment: ${{ needs.set-environment.outputs.environment }}
```

To enforce approval for production, create a GitHub Environment named exactly:

```text
prod
```

Then configure:

```text
Repository Settings
  -> Environments
  -> prod
  -> Required reviewers
```

When code is merged from `uat` into `prod`, GitHub Actions pauses the `Deploy Infrastructure` job until an approved reviewer approves the `prod` environment deployment.

---

## Required AWS Permissions for Deployment

The GitHub Actions role needs permissions for:

```text
ECR repository creation and Docker image push
EC2/VPC networking and instance deployment
IAM EC2 instance role and instance profile creation
RDS MySQL deployment
S3 Terraform state read/write
```

A full IAM policy example is included here:

```text
docs/github-actions-iam-policy.json
```

During troubleshooting, full EC2 permission may be temporarily attached:

```json
{
  "Effect": "Allow",
  "Action": "ec2:*",
  "Resource": "*"
}
```

After deployment succeeds, replace broad permissions with scoped least-privilege permissions.

---

## Docker Image Build

### Frontend Dockerfile

The frontend container builds the React app and serves it through Nginx.

```text
frontend/Dockerfile
```

Nginx also proxies API traffic:

```text
/api -> backend private IP:8000
```

### Backend Dockerfile

The backend container runs FastAPI with Uvicorn.

```text
backend/Dockerfile
```

FastAPI connects to RDS using environment variables passed from EC2 user data.

---

## Database Initialization

On backend startup, FastAPI automatically:

```text
Creates the todos table if it does not exist
Inserts one test To-Do item if not already present
Starts the API service
```

Default seed item:

```text
Test To-Do item created during application initialization
```

Useful API endpoints:

```text
GET  /health
GET  /api/todos
POST /api/todos
POST /api/seed
```

---

## Test the Application

After Terraform apply completes, get the frontend public IP from Terraform outputs or EC2 console.

Open in a browser:

```text
http://<frontend-public-ip>
```

Test API through the frontend proxy:

```bash
curl http://<frontend-public-ip>/api/todos
```

Create another seeded test item:

```bash
curl -X POST http://<frontend-public-ip>/api/seed
```

Check health:

```bash
curl http://<frontend-public-ip>/api/health
```

Depending on the Nginx proxy configuration, health may also be available as:

```bash
curl http://<frontend-public-ip>/api/health
```

---

## Connect to the Database

RDS is private, so connect from the backend EC2 instance or through a tunnel.

From backend EC2:

```bash
sudo apt update
sudo apt install -y mysql-client
mysql -h <rds-endpoint> -P 3306 -u todo_admin -p
```

With SSL CA bundle:

```bash
sudo mkdir -p /certs
sudo curl -o /certs/global-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
mysql -h <rds-endpoint> \
  -P 3306 \
  --ssl-mode=VERIFY_IDENTITY \
  --ssl-ca=/certs/global-bundle.pem \
  -u todo_admin \
  -p
```

Then run:

```sql
USE todoapp;
SHOW TABLES;
SELECT * FROM todos;
```

---

## Operational Notes

- The backend EC2 is private and pulls Docker images from ECR through the NAT Gateway.
- The frontend EC2 is public and serves traffic on port 80.
- RDS is private and only accepts MySQL traffic from the backend security group.
- There is no load balancer, so the application endpoint is the frontend EC2 public IP.
- There is no autoscaling, so each layer uses one instance.
- There is no Route 53/ACM, so the frontend uses plain HTTP for this lab version.

---

## Environment-specific Terraform tfvars files

### Environment tfvars flow diagram

![Environment tfvars flow](assets/environment-tfvars-flow.svg)


This project now supports separate Terraform variable files per environment. Each environment has its own VPC CIDR, subnet CIDRs, instance sizing, database sizing, and tags. The deployment workflow automatically selects the correct file based on the branch or manual workflow input.

```text
terraform/
├── environments/
│   ├── dev.tfvars
│   ├── uat.tfvars
│   └── prod.tfvars
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── modules/
│   ├── network/
│   ├── security-tools/
│   ├── ecr/
│   ├── compute/
│   └── database/
└── templates/
    ├── user_data_frontend.sh.tftpl
    └── user_data_backend.sh.tftpl
```

### Environment branch mapping

```text
dev branch  -> terraform/environments/dev.tfvars  -> dev environment
uat branch  -> terraform/environments/uat.tfvars  -> uat environment
prod branch -> terraform/environments/prod.tfvars -> prod environment
```

### Remote state path per environment

The GitHub Actions workflow uses one S3 bucket, but stores each environment in a separate state key:

```text
s3://react-js-application-terraform-state-866934333672/react-js-application/dev/terraform.tfstate
s3://react-js-application-terraform-state-866934333672/react-js-application/uat/terraform.tfstate
s3://react-js-application-terraform-state-866934333672/react-js-application/prod/terraform.tfstate
```

### What belongs in each tfvars file

Each `.tfvars` file contains non-sensitive environment configuration:

```hcl
aws_region   = "us-east-1"
project_name = "react-js-application"
environment  = "dev"

vpc_cidr                 = "10.40.0.0/16"
public_subnet_cidrs      = ["10.40.1.0/24", "10.40.2.0/24"]
private_app_subnet_cidrs = ["10.40.11.0/24", "10.40.12.0/24"]
private_db_subnet_cidrs  = ["10.40.21.0/24", "10.40.22.0/24"]

instance_type        = "t3.micro"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
```

Do not store database passwords in `.tfvars`. The workflow passes the database password securely from the GitHub secret:

```text
DB_PASSWORD
```

### Manual deployment by environment

Use **Actions → Docker Build Test Push / Deploy Infrastructure → Run workflow**, then choose:

```text
environment: dev | uat | prod
terraform_action: plan | apply | destroy
```

### CI/CD flow with environment tfvars

```text
GitHub branch or manual input
        |
        v
Resolve environment
        |
        v
Select terraform/environments/<env>.tfvars
        |
        v
Terraform init with S3 backend key: react-js-application/<env>/terraform.tfstate
        |
        v
Terraform validate and plan
        |
        v
Build Docker images
        |
        v
Push images to ECR path: react-js-application/<env>/...
        |
        v
Test containers
        |
        v
Terraform apply using the selected tfvars file
```

---

---

## Fix: required environment tfvars files

The deploy workflow validates that the environment-specific tfvars file exists before running Terraform:

```text
terraform/environments/dev.tfvars
terraform/environments/uat.tfvars
terraform/environments/prod.tfvars
```

The selected file is based on branch or manual workflow input:

```text
dev branch  -> terraform/environments/dev.tfvars
uat branch  -> terraform/environments/uat.tfvars
prod branch -> terraform/environments/prod.tfvars
```

Do not place these files under `.github/workflows` or another folder. They must stay under `terraform/environments/` because the deploy workflow runs Terraform from the `terraform` directory and passes:

```bash
-var-file="environments/${ENVIRONMENT}.tfvars"
```

---

## Repository Folder Layout Update

This project is designed to live inside a repository repository root. The GitHub workflows remain at the repository root under `.github/workflows`, while application and Terraform code live at the repository root.

```text
repo-root/
├── .github/
│   └── workflows/
│       ├── docker-build-push.yml
│       └── deploy.yml
├── frontend/
├── backend/
├── terraform/
    │   ├── environments/
    │   │   ├── dev.tfvars
    │   │   ├── uat.tfvars
    │   │   └── prod.tfvars
    │   ├── modules/
    │   │   ├── network/
    │   │   ├── security-tools/
    │   │   ├── ecr/
    │   │   ├── compute/
    │   │   └── database/
    │   ├── templates/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── versions.tf
├── assets/
└── docs/
```

### Workflow path configuration

Both workflows now use:

```yaml
env:
  APP_DIR: .
```

Terraform commands run from:

```text
terraform
```

The environment tfvars files are resolved as:

```text
terraform/environments/dev.tfvars
terraform/environments/uat.tfvars
terraform/environments/prod.tfvars
```

Docker build contexts are:

```text
frontend
backend
```

---

## Separate Frontend and Backend Instance Types

The frontend and backend EC2 workloads can now use different instance sizes. Configure them per environment in `terraform/environments/<env>.tfvars`:

```hcl
frontend_instance_type = "t3.micro"
backend_instance_type  = "t3.small"
```

Terraform passes these into the compute module separately:

```hcl
frontend_instance_type = var.frontend_instance_type
backend_instance_type  = var.backend_instance_type
```

This lets you scale the FastAPI backend independently from the React frontend without changing both instances at the same time.
