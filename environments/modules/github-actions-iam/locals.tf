locals {
  name_prefix               = "${var.project}-${var.environment}"
  ci_name_prefix            = "${local.name_prefix}-github-terraform"
  plan_role_name            = "${local.ci_name_prefix}-plan"
  apply_role_name           = "${local.ci_name_prefix}-apply"
  plan_policy_name          = "${local.ci_name_prefix}-plan"
  apply_policy_name         = "${local.ci_name_prefix}-apply"
  application_role_patterns = ["${local.name_prefix}-web-*", "${local.name_prefix}-app-*"]
  deployment_app_ssm_prefix = coalesce(var.deployment_app_ssm_prefix, "/${var.environment}/deployment-app")

  plan_role_arn            = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.plan_role_name}"
  apply_role_arn           = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.apply_role_name}"
  plan_policy_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/${local.plan_policy_name}"
  apply_policy_arn         = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/${local.apply_policy_name}"
  github_oidc_provider_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Purpose     = "github-actions-iam"
  }
}

data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
