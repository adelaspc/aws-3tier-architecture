output "github_oidc_provider_arn" {
  value = module.github_actions_iam.oidc_provider_arn
}

output "terraform_plan_role_arn" {
  value = module.github_actions_iam.plan_role_arn
}

output "terraform_apply_role_arn" {
  value = module.github_actions_iam.apply_role_arn
}

output "app_deploy_role_arn" {
  value = module.github_actions_iam.app_deploy_role_arn
}

output "terraform_plan_policy_arn" {
  value = module.github_actions_iam.plan_policy_arn
}

output "terraform_apply_policy_arn" {
  value = module.github_actions_iam.apply_policy_arn
}

output "app_deploy_policy_arn" {
  value = module.github_actions_iam.app_deploy_policy_arn
}

output "plan_trust_policy_json" {
  value = module.github_actions_iam.plan_trust_policy_json
}

output "apply_trust_policy_json" {
  value = module.github_actions_iam.apply_trust_policy_json
}

output "app_deploy_trust_policy_json" {
  value = module.github_actions_iam.app_deploy_trust_policy_json
}

output "plan_permission_policy_json" {
  value = module.github_actions_iam.plan_permission_policy_json
}

output "apply_permission_policy_json" {
  value = module.github_actions_iam.apply_permission_policy_json
}

output "app_deploy_permission_policy_json" {
  value = module.github_actions_iam.app_deploy_permission_policy_json
}
