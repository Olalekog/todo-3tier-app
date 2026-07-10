output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "public_subnet_vpc_ids" { value = aws_subnet.public[*].vpc_id }
output "private_app_subnet_ids" { value = aws_subnet.private_app[*].id }
output "private_app_subnet_vpc_ids" { value = aws_subnet.private_app[*].vpc_id }
output "private_db_subnet_ids" { value = aws_subnet.private_db[*].id }
output "private_db_subnet_vpc_ids" { value = aws_subnet.private_db[*].vpc_id }
