output "oidc_provider_arn" {
  description = "ARN of the existing GitHub Actions OIDC provider."
  value       = data.aws_iam_openid_connect_provider.github.arn
}

output "plan_role_arn" {
  description = "ARN of the Terraform plan role."
  value       = aws_iam_role.plan.arn
}

output "apply_role_arn" {
  description = "ARN of the Terraform apply role."
  value       = aws_iam_role.apply.arn
}

output "app_deploy_role_arn" {
  description = "ARN of the application deployment role."
  value       = aws_iam_role.app_deploy.arn
}

output "plan_policy_arn" {
  description = "ARN of the Terraform plan permissions policy."
  value       = aws_iam_policy.plan.arn
}

output "apply_policy_arn" {
  description = "ARN of the Terraform apply permissions policy."
  value       = aws_iam_policy.apply.arn
}

output "app_deploy_policy_arn" {
  description = "ARN of the application deployment permissions policy."
  value       = aws_iam_policy.app_deploy.arn
}

output "plan_trust_policy_json" {
  description = "Rendered trust policy JSON for the Terraform plan role."
  value       = data.aws_iam_policy_document.plan_trust.json
}

output "apply_trust_policy_json" {
  description = "Rendered trust policy JSON for the Terraform apply role."
  value       = data.aws_iam_policy_document.apply_trust.json
}

output "app_deploy_trust_policy_json" {
  description = "Rendered trust policy JSON for the application deployment role."
  value       = data.aws_iam_policy_document.app_deploy_trust.json
}

output "plan_permission_policy_json" {
  description = "Rendered permissions policy JSON for the Terraform plan role."
  value       = data.aws_iam_policy_document.plan_permissions.json
}

output "apply_permission_policy_json" {
  description = "Rendered permissions policy JSON for the Terraform apply role."
  value       = data.aws_iam_policy_document.apply_permissions.json
}

output "app_deploy_permission_policy_json" {
  description = "Rendered permissions policy JSON for the application deployment role."
  value       = data.aws_iam_policy_document.app_deploy_permissions.json
}
