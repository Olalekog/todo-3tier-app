# Architecture and Flow Diagrams

This document provides the architecture, deployment, and request flows for the Dockerized To-Do 3-tier AWS application.

## Architecture Diagram

![Dockerized To-Do 3-Tier Architecture](../assets/architecture-diagram.svg)

## Deployment Flow

![GitHub Actions Deployment Flow](../assets/deployment-flow.svg)

```mermaid
flowchart TD
    A[Push to dev/main or manual workflow run] --> B[GitHub Actions]
    B --> C[Assume AWS role through OIDC]
    C --> D[Terraform init with S3 backend]
    D --> E[Terraform validate]
    E --> F[Create ECR repositories]
    F --> G[Build Docker images]
    G --> H[Push images to ECR]
    H --> I[Terraform apply full stack]
    I --> J[Frontend EC2 pulls React/Nginx image]
    I --> K[Backend EC2 pulls FastAPI image]
    J --> L[Application available on frontend public IP]
    K --> L
```

## Application Request Flow

![Application Request Flow](../assets/request-flow.svg)

```mermaid
flowchart LR
    User[User Browser] -->|HTTP :80| Frontend[Public Frontend EC2\nReact + Nginx Docker]
    Frontend -->|Proxy /api :8000| Backend[Private Backend EC2\nFastAPI Docker]
    Backend -->|MySQL :3306| DB[(Private RDS MySQL)]
```

## Security Group Flow

```mermaid
flowchart LR
    Internet[Internet] -->|80| FESG[Frontend Security Group]
    Admin[Admin IP CIDR] -->|22 optional| FESG
    FESG -->|8000| BESG[Backend Security Group]
    BESG -->|3306| DBSG[Database Security Group]
```

## Network Placement

| Component | Placement | Public IP | Main inbound access |
|---|---|---:|---|
| Frontend EC2 | Public subnet | Yes | Internet on port 80 |
| Backend EC2 | Private app subnet | No | Frontend SG on port 8000 |
| RDS MySQL | Private DB subnets | No | Backend SG on port 3306 |
| NAT Gateway | Public subnet | Yes | Outbound path for private EC2 |
| ECR | AWS regional service | N/A | Image pull/push through AWS APIs |

## Excluded Services

This simplified deployment intentionally excludes ALB, ASG, Route 53, ACM, Cognito, Kubernetes, app-created KMS, and DynamoDB backend locking.
