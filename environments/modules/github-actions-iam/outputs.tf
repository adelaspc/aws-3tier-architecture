output "oidc_provider_arn" {
  value = data.aws_iam_openid_connect_provider.github.arn
}

output "plan_role_arn" {
  value = aws_iam_role.plan.arn
}

output "apply_role_arn" {
  value = aws_iam_role.apply.arn
}

output "app_deploy_role_arn" {
  value = aws_iam_role.app_deploy.arn
}

output "plan_policy_arn" {
  value = aws_iam_policy.plan.arn
}

output "apply_policy_arn" {
  value = aws_iam_policy.apply.arn
}

output "app_deploy_policy_arn" {
  value = aws_iam_policy.app_deploy.arn
}

output "plan_trust_policy_json" {
  value = data.aws_iam_policy_document.plan_trust.json
}

output "apply_trust_policy_json" {
  value = data.aws_iam_policy_document.apply_trust.json
}

output "app_deploy_trust_policy_json" {
  value = data.aws_iam_policy_document.app_deploy_trust.json
}

output "plan_permission_policy_json" {
  value = data.aws_iam_policy_document.plan_permissions.json
}

output "apply_permission_policy_json" {
  value = data.aws_iam_policy_document.apply_permissions.json
}

output "app_deploy_permission_policy_json" {
  value = data.aws_iam_policy_document.app_deploy_permissions.json
}
