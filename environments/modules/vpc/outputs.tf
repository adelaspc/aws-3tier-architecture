output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs for public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "web_subnet_ids" {
  description = "IDs for web EC2 subnets"
  value       = [for subnet in aws_subnet.web_private : subnet.id]
}

output "app_subnet_ids" {
  description = "IDs for app EC2 subnets"
  value       = [for subnet in aws_subnet.app_private : subnet.id]
}

output "db_subnet_ids" {
  description = "IDs for database subnets"
  value       = [for subnet in aws_subnet.db_private : subnet.id]
}

output "db_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.main.name
}
