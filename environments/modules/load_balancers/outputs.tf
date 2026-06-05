output "public_alb_dns_name" {
  value = aws_lb.public_lb.dns_name
}

output "public_web_target_group_arn" {
  value = aws_lb_target_group.web.arn
}

output "public_alb_arn" {
  value = aws_lb.public_lb.arn
}

output "acm_certificate_arn" {
  value = local.certificate_arn
}

output "internal_alb_dns_name" {
  value = aws_lb.internal.dns_name
}

output "internal_alb_zone_id" {
  value = aws_lb.internal.zone_id
}

output "internal_app_target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "internal_alb_arn" {
  value = aws_lb.internal.arn
}
