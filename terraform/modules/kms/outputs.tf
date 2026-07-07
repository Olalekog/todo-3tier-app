output "key_arn" {
  description = "KMS key ARN."
  value       = aws_kms_key.this.arn
}

output "key_id" {
  description = "KMS key ID."
  value       = aws_kms_key.this.key_id
}

output "alias_name" {
  description = "KMS alias name when provided."
  value       = length(aws_kms_alias.this) > 0 ? aws_kms_alias.this[0].name : null
}
