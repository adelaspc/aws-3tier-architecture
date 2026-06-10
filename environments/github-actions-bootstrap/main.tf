module "github_actions_iam" {
  source = "../modules/github-actions-iam"

  project                   = var.project
  environment               = var.environment
  github_repository         = var.github_repository
  github_environment        = var.github_environment
  github_app_environment    = var.github_app_environment
  ecr_repository_name       = var.ecr_repository_name
  state_bucket_name         = var.state_bucket_name
  dev_state_key             = var.dev_state_key
  deployment_app_ssm_prefix = var.deployment_app_ssm_prefix
}
