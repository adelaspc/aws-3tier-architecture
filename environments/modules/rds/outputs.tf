output "endpoint" {
  description = "DNS address of the RDS instance."
  value       = aws_db_instance.main.address
}

output "port" {
  description = "Port of the RDS instance."
  value       = aws_db_instance.main.port
}

output "master_username" {
  description = "Master username for the RDS instance."
  value       = var.master_username
}

output "master_user_secret_arn" {
  description = "ARN of the AWS-managed RDS master user secret."
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
