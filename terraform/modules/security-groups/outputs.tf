output "frontend_security_group_id" { value = aws_security_group.frontend.id }
output "backend_security_group_id" { value = aws_security_group.backend.id }
output "db_security_group_id" { value = aws_security_group.db.id }
