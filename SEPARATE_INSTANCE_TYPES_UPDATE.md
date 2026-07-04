# Separate Frontend and Backend Instance Types

Updated Terraform so frontend and backend EC2 workloads are sized independently.

## Changed files

```text
terraform/variables.tf
terraform/main.tf
terraform/modules/compute/variables.tf
terraform/modules/compute/main.tf
terraform/environments/dev.tfvars
terraform/environments/uat.tfvars
terraform/environments/prod.tfvars
terraform/terraform.tfvars.example
README.md
docs/architecture.md
```

## New variables

```hcl
frontend_instance_type = "t3.micro"
backend_instance_type  = "t3.small"
```

## Removed variable

```hcl
instance_type
```

The old shared `instance_type` variable has been replaced so changing one workload does not automatically resize the other.
