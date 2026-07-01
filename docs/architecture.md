# Dockerized 3-Tier To-Do App Architecture

```text
Browser
  |
  | HTTP :80
  v
Frontend EC2 instance in public subnet
  - Docker
  - React static files
  - Nginx
  - Nginx proxies /api
  |
  | Private traffic :8000
  v
Backend EC2 instance in private app subnet
  - Docker
  - FastAPI
  - Uvicorn
  |
  | Private traffic :3306
  v
RDS MySQL in private DB subnets
```

## Container Packaging

The frontend and backend are packaged separately:

```text
frontend/Dockerfile -> ECR frontend repository
backend/Dockerfile  -> ECR backend repository
```

GitHub Actions builds both images and pushes them to Amazon ECR.

## Runtime

```text
Frontend EC2 pulls frontend image from ECR and runs container on port 80.
Backend EC2 pulls backend image from ECR and runs container on port 8000.
RDS accepts MySQL traffic only from backend security group.
```

## Excluded Services

```text
No ALB
No ASG
No Route 53
No ACM
No Cognito
No app-created KMS key
```
