output "github_oidc_provider_arn" {
  description = "ARN of the existing GitHub Actions OIDC provider."
  value       = module.github_actions_iam.oidc_provider_arn
}

output "terraform_plan_role_arn" {
  description = "ARN of the Terraform plan role."
  value       = module.github_actions_iam.plan_role_arn
}

output "terraform_apply_role_arn" {
  description = "ARN of the Terraform apply role."
  value       = module.github_actions_iam.apply_role_arn
}

output "app_deploy_role_arn" {
  description = "ARN of the application deployment role."
  value       = module.github_actions_iam.app_deploy_role_arn
}

output "terraform_plan_policy_arn" {
  description = "ARN of the Terraform plan permissions policy."
  value       = module.github_actions_iam.plan_policy_arn
}

output "terraform_apply_policy_arn" {
  description = "ARN of the Terraform apply permissions policy."
  value       = module.github_actions_iam.apply_policy_arn
}

output "app_deploy_policy_arn" {
  description = "ARN of the application deployment permissions policy."
  value       = module.github_actions_iam.app_deploy_policy_arn
}

output "plan_trust_policy_json" {
  description = "Rendered trust policy JSON for the Terraform plan role."
  value       = module.github_actions_iam.plan_trust_policy_json
}

output "apply_trust_policy_json" {
  description = "Rendered trust policy JSON for the Terraform apply role."
  value       = module.github_actions_iam.apply_trust_policy_json
}

output "app_deploy_trust_policy_json" {
  description = "Rendered trust policy JSON for the application deployment role."
  value       = module.github_actions_iam.app_deploy_trust_policy_json
}

output "plan_permission_policy_json" {
  description = "Rendered permissions policy JSON for the Terraform plan role."
  value       = module.github_actions_iam.plan_permission_policy_json
}

output "apply_permission_policy_json" {
  description = "Rendered permissions policy JSON for the Terraform apply role."
  value       = module.github_actions_iam.apply_permission_policy_json
}

output "app_deploy_permission_policy_json" {
  description = "Rendered permissions policy JSON for the application deployment role."
  value       = module.github_actions_iam.app_deploy_permission_policy_json
}

output "github_actions_repository_variables" {
  description = "GitHub repository variables used by the Terraform and application deployment workflows."
  value = {
    AWS_REGION                   = var.region
    AWS_TERRAFORM_PLAN_ROLE_ARN  = module.github_actions_iam.plan_role_arn
    AWS_TERRAFORM_APPLY_ROLE_ARN = module.github_actions_iam.apply_role_arn
    AWS_APP_DEPLOY_ROLE_ARN      = module.github_actions_iam.app_deploy_role_arn
    TF_STATE_BUCKET              = var.state_bucket_name
    TF_STATE_KEY                 = var.dev_state_key
    ECR_REPOSITORY               = var.ecr_repository_name
  }
}
