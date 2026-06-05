output "web_asg_name" {
  value = aws_autoscaling_group.web.name
}

output "app_asg_name" {
  value = aws_autoscaling_group.app.name
}

output "backend_image_tag_parameter_name" {
  value = aws_ssm_parameter.image_tag["app"].name
}

output "frontend_image_tag_parameter_name" {
  value = aws_ssm_parameter.image_tag["web"].name
}
