provider "aws" {
  region                      = "eu-central-1"
  access_key                  = "mock-access-key"
  secret_key                  = "mock-secret-key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
}

override_data {
  target = data.aws_partition.current
  values = {
    partition = "aws"
  }
}

override_data {
  target = data.aws_region.current
  values = {
    region = "eu-central-1"
  }
}

override_data {
  target = data.aws_caller_identity.current
  values = {
    account_id = "111122223333"
  }
}

override_data {
  target = data.aws_iam_openid_connect_provider.github
  values = {
    arn = "arn:aws:iam::111122223333:oidc-provider/token.actions.githubusercontent.com"
    url = "token.actions.githubusercontent.com"
  }
}

run "github_actions_security_model" {
  command = plan

  variables {
    project                = "deployment-notes"
    environment            = "dev"
    github_repository      = "adelaspc/aws-3tier-architecture"
    github_environment     = "terraform-dev"
    github_app_environment = "app-dev"
    ecr_repository_name    = "deployments-notes-app"
    state_bucket_name      = "deployment-notes-dev-terraform-state"
    dev_state_key          = "aws-3tier-architecture/dev/terraform.tfstate"
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.plan_trust.json, "repo:adelaspc/aws-3tier-architecture:pull_request")
    error_message = "Plan trust must allow internal pull requests."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.plan_trust.json, "repo:adelaspc/aws-3tier-architecture:ref:refs/heads/*")
    error_message = "Plan trust must allow workflow_dispatch from repository branches."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.apply_trust.json, "repo:adelaspc/aws-3tier-architecture:environment:terraform-dev")
    error_message = "Apply trust must use the protected terraform-dev environment subject."
  }

  assert {
    condition     = !strcontains(data.aws_iam_policy_document.apply_trust.json, "pull_request") && !strcontains(data.aws_iam_policy_document.apply_trust.json, "refs/heads")
    error_message = "Apply trust must not accept pull requests or branch subjects."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.app_deploy_trust.json, "repo:adelaspc/aws-3tier-architecture:environment:app-dev")
    error_message = "App deployment trust must use the protected app-dev environment subject."
  }

  assert {
    condition     = !strcontains(data.aws_iam_policy_document.app_deploy_trust.json, "pull_request") && !strcontains(data.aws_iam_policy_document.app_deploy_trust.json, "refs/heads")
    error_message = "App deployment trust must not accept pull requests or branch subjects."
  }

  assert {
    condition     = !strcontains(data.aws_iam_policy_document.plan_permissions.json, "ec2:Create") && !strcontains(data.aws_iam_policy_document.plan_permissions.json, "ec2:RunInstances")
    error_message = "Plan permissions must not mutate EC2 infrastructure."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.plan_permissions.json, "DenyAssumingOtherRoles")
    error_message = "Plan permissions must explicitly deny sts:AssumeRole."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.plan_permissions.json, "aws-3tier-architecture/dev/terraform.tfstate.tflock") && strcontains(data.aws_iam_policy_document.plan_permissions.json, "s3:DeleteObject")
    error_message = "Terraform roles must be able to manage the native S3 lockfile."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.plan_permissions.json, "ssm:ListTagsForResource") && strcontains(data.aws_iam_policy_document.plan_permissions.json, "parameter/dev/deployment-app/*")
    error_message = "Plan permissions must allow reading tags for application SSM parameters."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.plan_permissions.json, "rds:ListTagsForResource")
    error_message = "Plan permissions must allow reading tags for RDS resources."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.apply_permissions.json, "iam:PassedToService") && strcontains(data.aws_iam_policy_document.apply_permissions.json, "ec2.amazonaws.com")
    error_message = "PassRole must be limited to EC2 through iam:PassedToService."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "repository/deployments-notes-app") && strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "ecr:PutImage") && strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "ecr:BatchGetImage") && strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "ecr:GetDownloadUrlForLayer")
    error_message = "App deployment must read and push images only in the configured ECR repository."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "autoScalingGroupName/deployment-notes-dev-app-asg") && strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "autoScalingGroupName/deployment-notes-dev-web-asg")
    error_message = "App deployment refresh permissions must be scoped to the app and web ASGs."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "document/AWS-RunShellScript") && strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "ssm:SendCommand")
    error_message = "App deployment must use SSM Run Command for database migrations."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "parameter/dev/deployment-app/images/*") && !strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "ssm:GetParameterHistory")
    error_message = "App deployment parameter writes must be limited to image tags."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.app_deploy_permissions.json, "DenyAssumingOtherRoles")
    error_message = "App deployment permissions must explicitly deny sts:AssumeRole."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.apply_permissions.json, "kms:CreateGrant") && strcontains(data.aws_iam_policy_document.apply_permissions.json, "kms:GrantIsForAWSResource") && strcontains(data.aws_iam_policy_document.apply_permissions.json, "rds.eu-central-1.amazonaws.com")
    error_message = "KMS grants must be restricted to AWS resources used through RDS."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.apply_permissions.json, "kms:ViaService") && strcontains(data.aws_iam_policy_document.apply_permissions.json, "secretsmanager.eu-central-1.amazonaws.com")
    error_message = "KMS key usage must be restricted to RDS and Secrets Manager service calls."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.apply_permissions.json, "secretsmanager:CreateSecret") && strcontains(data.aws_iam_policy_document.apply_permissions.json, "secret:rds!db-*") && !strcontains(data.aws_iam_policy_document.apply_permissions.json, "secretsmanager:GetSecretValue")
    error_message = "Apply permissions must manage only RDS master-user secrets without reading their values."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.apply_permissions.json, "role/deployment-notes-dev-web-*") && strcontains(data.aws_iam_policy_document.apply_permissions.json, "role/deployment-notes-dev-app-*")
    error_message = "Application IAM permissions must be scoped to web/app role prefixes."
  }

  assert {
    condition     = !strcontains(data.aws_iam_policy_document.apply_permissions.json, "arn:aws:iam::111122223333:role/*")
    error_message = "Apply permissions must not manage arbitrary account roles."
  }

  assert {
    condition = alltrue([
      for statement in jsondecode(data.aws_iam_policy_document.apply_permissions.json).Statement :
      statement.Effect != "Allow" || !strcontains(jsonencode(statement.Action), "\"iam:CreatePolicy\"")
      ]) && alltrue([
      for statement in jsondecode(data.aws_iam_policy_document.apply_permissions.json).Statement :
      statement.Effect != "Allow" || !strcontains(jsonencode(statement.Action), "\"iam:*\"")
    ])
    error_message = "Apply permissions must not create arbitrary managed policies or receive wildcard IAM access."
  }

  assert {
    condition     = !strcontains(data.aws_iam_policy_document.apply_permissions.json, "AdministratorAccess")
    error_message = "Apply permissions must never reference AdministratorAccess."
  }

  assert {
    condition     = strcontains(data.aws_iam_policy_document.apply_permissions.json, "ProtectCIRoles") && strcontains(data.aws_iam_policy_document.apply_permissions.json, local.app_deploy_role_arn) && strcontains(data.aws_iam_policy_document.apply_permissions.json, "ProtectCIPolicies") && strcontains(data.aws_iam_policy_document.apply_permissions.json, local.app_deploy_policy_arn) && strcontains(data.aws_iam_policy_document.apply_permissions.json, "ProtectGitHubOIDCProvider")
    error_message = "Apply permissions must explicitly protect all CI roles, policies, and the OIDC provider."
  }
}
