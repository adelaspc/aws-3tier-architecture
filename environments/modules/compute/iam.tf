data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ec2" {
  for_each = toset(["web", "app"])

  name               = "${local.name_prefix}-${each.key}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  for_each = aws_iam_role.ec2

  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  for_each = aws_iam_role.ec2

  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  for_each = aws_iam_role.ec2

  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

locals {
  runtime_parameters = {
    web = [
      local.cloudwatch_agent_parameter_names.web,
      local.image_tag_parameter_names.web,
    ]
    app = [
      local.database_url_parameter_name,
      local.cloudwatch_agent_parameter_names.app,
      local.image_tag_parameter_names.app,
    ]
  }

  runtime_log_groups = {
    web = [
      local.log_group_names.web.application,
      local.log_group_names.web.bootstrap,
    ]
    app = [
      local.log_group_names.app.application,
      local.log_group_names.app.bootstrap,
    ]
  }
}

data "aws_iam_policy_document" "runtime" {
  for_each = aws_iam_role.ec2

  statement {
    sid     = "ReadDeploymentNotesParameters"
    actions = ["ssm:GetParameter"]
    resources = [
      for name in local.runtime_parameters[each.key] :
      "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter${name}"
    ]
  }

  statement {
    sid = "ManageDeploymentNotesLogGroups"
    actions = [
      "logs:CreateLogGroup",
      "logs:PutRetentionPolicy",
    ]
    resources = [
      for name in local.runtime_log_groups[each.key] :
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${name}:*"
    ]
  }

  statement {
    sid       = "DescribeLogGroups"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "runtime" {
  for_each = aws_iam_role.ec2

  name   = "${local.name_prefix}-${each.key}-runtime"
  role   = each.value.id
  policy = data.aws_iam_policy_document.runtime[each.key].json
}

resource "aws_iam_instance_profile" "ec2" {
  for_each = aws_iam_role.ec2

  name = "${local.name_prefix}-${each.key}-ec2-profile"
  role = each.value.name
  tags = local.common_tags
}
