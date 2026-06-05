output "public_application_url" {
  value = "https://${module.dns.public_fqdn}"
}

output "acm_certificate_arn" {
  value = module.load_balancers.acm_certificate_arn
}

output "private_api_fqdn" {
  value = module.dns.private_fqdn
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "rds_master_user_secret_arn" {
  value = module.rds.master_user_secret_arn
}

output "backend_image_tag_parameter_name" {
  value = module.compute.backend_image_tag_parameter_name
}

output "frontend_image_tag_parameter_name" {
  value = module.compute.frontend_image_tag_parameter_name
}
