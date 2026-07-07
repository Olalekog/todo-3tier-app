# Move existing EC2 instances from the old module.compute resources into two
# separate root module blocks that still use the same reusable ./modules/compute source.
# This helps Terraform avoid destroying/recreating EC2 instances only because the module path changed.

moved {
  from = module.compute.aws_instance.backend
  to   = module.backend_compute.aws_instance.this
}

moved {
  from = module.compute.aws_instance.frontend
  to   = module.frontend_compute.aws_instance.this
}

# Move the old shared IAM resources to the backend module where possible.
# The frontend module will manage its own IAM role/profile going forward.

moved {
  from = module.compute.aws_iam_role.ec2_ecr_pull
  to   = module.backend_compute.aws_iam_role.ec2_ecr_pull
}

moved {
  from = module.compute.aws_iam_instance_profile.ec2_ecr_pull
  to   = module.backend_compute.aws_iam_instance_profile.this
}

moved {
  from = module.compute.aws_iam_role_policy_attachment.ec2_ecr_read_only
  to   = module.backend_compute.aws_iam_role_policy_attachment.ecr_read_only
}

moved {
  from = aws_security_group.sonarqube
  to   = module.security_integration.aws_security_group.sonarqube
}

moved {
  from = aws_iam_role.sonarqube
  to   = module.security_integration.aws_iam_role.sonarqube
}

moved {
  from = aws_iam_role_policy_attachment.sonarqube_ssm
  to   = module.security_integration.aws_iam_role_policy_attachment.sonarqube_ssm
}

moved {
  from = aws_iam_instance_profile.sonarqube
  to   = module.security_integration.aws_iam_instance_profile.sonarqube
}

moved {
  from = aws_instance.sonarqube
  to   = module.security_integration.aws_instance.sonarqube
}

moved {
  from = module.security_groups.module.deploy.aws_security_group.frontend
  to   = module.security_groups.aws_security_group.frontend
}

moved {
  from = module.security_groups.module.deploy.aws_security_group.backend
  to   = module.security_groups.aws_security_group.backend
}

moved {
  from = module.security_groups.module.deploy.aws_security_group.database
  to   = module.security_groups.aws_security_group.database
}
