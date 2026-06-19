output "web_asg_name" {
  description = "Name of the web Auto Scaling Group."
  value       = aws_autoscaling_group.web.name
}

output "app_asg_name" {
  description = "Name of the app Auto Scaling Group."
  value       = aws_autoscaling_group.app.name
}

output "backend_image_tag_parameter_name" {
  description = "SSM parameter name containing the backend image tag."
  value       = aws_ssm_parameter.image_tag["app"].name
}

output "frontend_image_tag_parameter_name" {
  description = "SSM parameter name containing the frontend image tag."
  value       = aws_ssm_parameter.image_tag["web"].name
}

output "database_config_parameter_name" {
  description = "SSM parameter name containing non-secret database connection metadata."
  value       = aws_ssm_parameter.database_config.name
}
