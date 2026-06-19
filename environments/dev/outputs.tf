output "public_application_url" {
  description = "HTTPS URL for the public application."
  value       = "https://${module.dns.public_fqdn}"
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate used by the public HTTPS listener."
  value       = module.load_balancers.acm_certificate_arn
}

output "private_api_fqdn" {
  description = "Private Route 53 hostname for the internal API."
  value       = module.dns.private_fqdn
}

output "rds_endpoint" {
  description = "DNS address of the RDS instance."
  value       = module.rds.endpoint
}

output "rds_master_user_secret_arn" {
  description = "ARN of the AWS-managed RDS master user secret."
  value       = module.rds.master_user_secret_arn
}

output "web_asg_name" {
  description = "Name of the web Auto Scaling Group."
  value       = module.compute.web_asg_name
}

output "app_asg_name" {
  description = "Name of the app Auto Scaling Group."
  value       = module.compute.app_asg_name
}

output "backend_image_tag_parameter_name" {
  description = "SSM parameter name containing the backend image tag."
  value       = module.compute.backend_image_tag_parameter_name
}

output "frontend_image_tag_parameter_name" {
  description = "SSM parameter name containing the frontend image tag."
  value       = module.compute.frontend_image_tag_parameter_name
}

output "database_config_parameter_name" {
  description = "SSM parameter name containing non-secret database connection metadata."
  value       = module.compute.database_config_parameter_name
}

output "alb_access_logs_bucket_name" {
  description = "Name of the ALB access logs bucket when access logs are enabled"
  value       = module.load_balancers.alb_access_logs_bucket_name
}

output "github_actions_app_variables" {
  description = "GitHub repository variables used by the application deployment workflow."
  value = {
    APP_ENV                           = var.environment
    APP_ASG_NAME                      = module.compute.app_asg_name
    WEB_ASG_NAME                      = module.compute.web_asg_name
    BACKEND_CONTAINER_NAME            = var.backend_container_name
    ECR_REPOSITORY                    = var.ecr_repository_name
    DATABASE_CONFIG_PARAMETER_NAME    = module.compute.database_config_parameter_name
    BACKEND_IMAGE_TAG_PARAMETER_NAME  = module.compute.backend_image_tag_parameter_name
    FRONTEND_IMAGE_TAG_PARAMETER_NAME = module.compute.frontend_image_tag_parameter_name
  }
}
