output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "EC2 private IP address."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "EC2 public IP address."
  value       = aws_instance.this.public_ip
}
