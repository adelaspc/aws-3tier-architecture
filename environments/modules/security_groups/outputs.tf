output "public_alb_sg_id" {
  description = "Security group ID for the public ALB"
  value       = aws_security_group.public_alb.id
}

output "internal_alb_sg_id" {
  description = "Security group ID for the internal ALB"
  value       = aws_security_group.internal_alb.id
}

output "web_ec2_sg_id" {
  description = "Security group ID for the web EC2 instances"
  value       = aws_security_group.web_ec2.id
}

output "app_ec2_sg_id" {
  description = "Security group ID for the app EC2 instances"
  value       = aws_security_group.app_ec2.id
}

output "db_sg_id" {
  description = "Security group ID for the database"
  value       = aws_security_group.db.id
}

