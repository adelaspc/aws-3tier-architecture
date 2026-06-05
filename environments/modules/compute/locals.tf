locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  deployment_app_prefix       = coalesce(var.deployment_app_ssm_prefix, "/${var.environment}/deployment-app")
  cloudwatch_log_group_prefix = coalesce(var.cloudwatch_log_group_prefix, "/${var.environment}/deployment-notes")

  image_tag_parameter_names = {
    app = "${local.deployment_app_prefix}/images/backend-tag"
    web = "${local.deployment_app_prefix}/images/frontend-tag"
  }

  cloudwatch_agent_parameter_names = {
    app = "${local.deployment_app_prefix}/cloudwatch-agent/backend"
    web = "${local.deployment_app_prefix}/cloudwatch-agent/frontend"
  }

  log_group_names = {
    app = {
      application = "${local.cloudwatch_log_group_prefix}/backend"
      bootstrap   = "${local.cloudwatch_log_group_prefix}/backend/bootstrap"
    }
    web = {
      application = "${local.cloudwatch_log_group_prefix}/frontend"
      bootstrap   = "${local.cloudwatch_log_group_prefix}/frontend/bootstrap"
    }
  }

  database_url_parameter_name = "${local.deployment_app_prefix}/db/database-url"
}
