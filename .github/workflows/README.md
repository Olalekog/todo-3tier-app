# Infrastructure Change Trigger Update

This package updates the workflows so changes are handled correctly:

## Docker workflow

`.github/workflows/docker-build-push.yml` now builds Docker images only when files under these paths change:

- `frontend/**`
- `backend/**`

That means Dockerfile changes and application code changes both trigger Docker build, test, push, and dev deploy with the new image SHA.

## Deploy workflow

`.github/workflows/deploy.yml` now runs the deploy build/test/deploy stages when infrastructure changes occur:

- `terraform/**`
- `.github/workflows/deploy.yml`

For infrastructure-only changes, the workflow uses `image_tag=latest` so it does not force a new Docker image.

## Behavior

- Frontend/backend changes: Docker build -> Docker test -> Docker push -> dev deploy with new SHA image.
- Terraform/deploy workflow changes: Deploy build -> Terraform validate/plan -> apply dev or plan uat/prod.
- No Docker image is rebuilt for infrastructure-only changes.
