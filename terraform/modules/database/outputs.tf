output "db_address" {
  description = "RDS database endpoint address."
  value       = aws_db_instance.this.address
}

output "db_endpoint" {
  description = "RDS database endpoint with port."
  value       = aws_db_instance.this.endpoint
}

output "db_port" {
  description = "RDS database port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name."
  value       = aws_db_instance.this.db_name
}
