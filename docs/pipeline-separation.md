# Pipeline Separation

This project uses two GitHub Actions workflows.

## 1. Docker Build Test and Push

File:

```text
.github/workflows/docker-build-push.yml
```

Purpose:

```text
Validate inputs
Create or update ECR repositories only
Build frontend Docker image
Build backend Docker image
Run local container tests
Push SHA and latest image tags to ECR
```

Image tags pushed:

```text
<account>.dkr.ecr.<region>.amazonaws.com/<project>/<environment>/todo-frontend:latest
<account>.dkr.ecr.<region>.amazonaws.com/<project>/<environment>/todo-frontend:<git-sha>
<account>.dkr.ecr.<region>.amazonaws.com/<project>/<environment>/todo-backend:latest
<account>.dkr.ecr.<region>.amazonaws.com/<project>/<environment>/todo-backend:<git-sha>
```

## 2. Terraform Deploy Todo App

File:

```text
.github/workflows/deploy.yml
```

Purpose:

```text
Validate promotion path
Select environment tfvars file
Run terraform fmt/init/validate/plan
Apply or destroy infrastructure
Deploy EC2 instances using selected Docker image tag
```

## Promotion Rules

```text
dev -> uat only
uat -> prod only
```

Production approval is controlled through GitHub Environments. Create a GitHub Environment named `prod` and add required reviewers.

## Deployment Sequence

```text
1. Push frontend/backend code to dev.
2. Docker workflow builds, tests, and pushes images.
3. Deploy workflow runs separately when Terraform changes are pushed or when manually triggered.
4. For manual deploys, pass the image tag from the Docker workflow summary.
```
