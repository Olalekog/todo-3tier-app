# Updated Code Notes

This package contains the latest corrected `react-js-application` code.

## Key fixes included

- Flattened repo layout: `.github`, `frontend`, `backend`, `terraform` at repository root.
- Project name remains `react-js-application`.
- Root `terraform/main.tf` uses one reusable compute module source, but separate root blocks:
  - `module "backend_compute"`
  - `module "frontend_compute"`
- Separate workload instance types:
  - `frontend_instance_type`
  - `backend_instance_type`
- Correct module argument names:
  - `availability_zones` for network module
  - `db_security_group_id` and `allocated_storage` for database module
- Correct `.tfvars` assignment syntax. No `variable {}` blocks in tfvars.
- Security group module supports `backend_allowed_cidr_blocks`.
- ECR existing repository import logic is preserved in deploy workflow.
- Deploy workflow uses Terraform plan JSON change detection to avoid apply when there are no infrastructure changes.
- `moved.tf` included to help avoid EC2 destroy/recreate due only to module path change.

## Replace repo content

Copy the contents of this package into your repo root, then run:

```bash
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/dev.tfvars"
```
