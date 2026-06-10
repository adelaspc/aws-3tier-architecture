module "vpc" {
  source = "../modules/vpc"

  project     = var.project
  environment = var.environment

  vpc_cidr       = var.vpc_cidr
  azs            = var.azs
  public_subnets = var.public_subnets
  web_subnets    = var.web_subnets
  app_subnets    = var.app_subnets
  db_subnets     = var.db_subnets
}


module "security_groups" {
  source = "../modules/security_groups"

  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "load_balancers" {
  source = "../modules/load_balancers"

  project                 = var.project
  environment             = var.environment
  certificate_domain_name = var.public_zone_name
  acm_certificate_arn     = var.acm_certificate_arn
  vpc_id                  = module.vpc.vpc_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  app_subnet_ids          = module.vpc.app_subnet_ids
  public_alb_sg_id        = module.security_groups.public_alb_sg_id
  internal_alb_sg_id      = module.security_groups.internal_alb_sg_id
}

module "compute" {
  source = "../modules/compute"

  project                                 = var.project
  environment                             = var.environment
  web_subnet_ids                          = module.vpc.web_subnet_ids
  app_subnet_ids                          = module.vpc.app_subnet_ids
  web_security_group_id                   = module.security_groups.web_ec2_sg_id
  app_security_group_id                   = module.security_groups.app_ec2_sg_id
  web_target_group_arn                    = module.load_balancers.public_web_target_group_arn
  app_target_group_arn                    = module.load_balancers.internal_app_target_group_arn
  internal_alb_dns_name                   = module.dns.private_fqdn
  custom_ami_id                           = var.custom_ami_id
  ecr_repository_name                     = var.ecr_repository_name
  initial_backend_image_tag               = var.initial_backend_image_tag
  initial_frontend_image_tag              = var.initial_frontend_image_tag
  deployment_app_ssm_prefix               = var.deployment_app_ssm_prefix
  cloudwatch_log_group_prefix             = var.cloudwatch_log_group_prefix
  backend_container_name                  = var.backend_container_name
  frontend_container_name                 = var.frontend_container_name
  backend_log_level                       = var.backend_log_level
  backend_gunicorn_workers                = var.backend_gunicorn_workers
  backend_gunicorn_threads                = var.backend_gunicorn_threads
  container_health_check_attempts         = var.container_health_check_attempts
  container_health_check_interval_seconds = var.container_health_check_interval_seconds
  instance_type                           = var.instance_type
  web_desired_capacity                    = var.web_desired_capacity
  app_desired_capacity                    = var.app_desired_capacity
}

module "rds" {
  source = "../modules/rds"

  project              = var.project
  environment          = var.environment
  db_subnet_group_name = module.vpc.db_subnet_group_name
  security_group_id    = module.security_groups.db_sg_id
  instance_class       = var.db_instance_class
  database_name        = var.database_name
  deletion_protection  = var.db_deletion_protection
}

module "dns" {
  source = "../modules/dns"

  vpc_id                = module.vpc.vpc_id
  cloudflare_zone_id    = var.cloudflare_zone_id
  public_record_name    = var.public_record_name
  public_alb_dns_name   = module.load_balancers.public_alb_dns_name
  cloudflare_proxied    = var.cloudflare_proxied
  private_zone_name     = var.private_zone_name
  internal_alb_dns_name = module.load_balancers.internal_alb_dns_name
  internal_alb_zone_id  = module.load_balancers.internal_alb_zone_id
}
