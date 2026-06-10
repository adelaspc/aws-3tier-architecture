data "aws_iam_openid_connect_provider" "github" {
  arn = local.github_oidc_provider_arn
}

data "aws_iam_policy_document" "plan_trust" {
  statement {
    sid     = "GitHubRepositoryPlan"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repository}:pull_request",
        "repo:${var.github_repository}:ref:refs/heads/*",
      ]
    }
  }
}

data "aws_iam_policy_document" "apply_trust" {
  statement {
    sid     = "GitHubEnvironmentApply"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:environment:${var.github_environment}"]
    }
  }
}

data "aws_iam_policy_document" "app_deploy_trust" {
  statement {
    sid     = "GitHubEnvironmentAppDeploy"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:environment:${var.github_app_environment}"]
    }
  }
}

resource "aws_iam_role" "plan" {
  name               = local.plan_role_name
  assume_role_policy = data.aws_iam_policy_document.plan_trust.json
  tags               = local.common_tags
}

resource "aws_iam_role" "apply" {
  name               = local.apply_role_name
  assume_role_policy = data.aws_iam_policy_document.apply_trust.json
  tags               = local.common_tags
}

resource "aws_iam_role" "app_deploy" {
  name               = local.app_deploy_role_name
  assume_role_policy = data.aws_iam_policy_document.app_deploy_trust.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "plan" {
  name   = local.plan_policy_name
  policy = data.aws_iam_policy_document.plan_permissions.json
  tags   = local.common_tags
}

resource "aws_iam_policy" "apply" {
  name   = local.apply_policy_name
  policy = data.aws_iam_policy_document.apply_permissions.json
  tags   = local.common_tags
}

resource "aws_iam_policy" "app_deploy" {
  name   = local.app_deploy_policy_name
  policy = data.aws_iam_policy_document.app_deploy_permissions.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "plan" {
  role       = aws_iam_role.plan.name
  policy_arn = aws_iam_policy.plan.arn
}

resource "aws_iam_role_policy_attachment" "apply" {
  role       = aws_iam_role.apply.name
  policy_arn = aws_iam_policy.apply.arn
}

resource "aws_iam_role_policy_attachment" "app_deploy" {
  role       = aws_iam_role.app_deploy.name
  policy_arn = aws_iam_policy.app_deploy.arn
}
