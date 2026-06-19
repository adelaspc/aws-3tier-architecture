output "public_alb_dns_name" {
  description = "DNS name of the public ALB."
  value       = aws_lb.public_lb.dns_name
}

output "public_web_target_group_arn" {
  description = "ARN of the public web target group."
  value       = aws_lb_target_group.web.arn
}

output "public_alb_arn" {
  description = "ARN of the public ALB."
  value       = aws_lb.public_lb.arn
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate used by the public HTTPS listener."
  value       = local.certificate_arn
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal ALB."
  value       = aws_lb.internal.dns_name
}

output "internal_alb_zone_id" {
  description = "Route 53 zone ID of the internal ALB."
  value       = aws_lb.internal.zone_id
}

output "internal_app_target_group_arn" {
  description = "ARN of the internal app target group."
  value       = aws_lb_target_group.app.arn
}

output "internal_alb_arn" {
  description = "ARN of the internal ALB."
  value       = aws_lb.internal.arn
}

output "alb_access_logs_bucket_name" {
  description = "Name of the ALB access logs bucket when access logs are enabled"
  value       = try(aws_s3_bucket.alb_logs[0].bucket, null)
}
