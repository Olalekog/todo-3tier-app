output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the EC2 instance, if assigned."
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance, if assigned."
  value       = aws_instance.this.public_dns
}

output "iam_role_name" {
  description = "IAM role name attached to the EC2 instance profile."
  value       = aws_iam_role.ec2_ecr_pull.name
}

output "instance_profile_name" {
  description = "IAM instance profile name."
  value       = aws_iam_instance_profile.this.name
}
