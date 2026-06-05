data "aws_ami" "custom" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "image-id"
    values = [var.custom_ami_id]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}-web-"
  image_id      = data.aws_ami.custom.id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2["web"].arn
  }

  vpc_security_group_ids = [var.web_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data/web.sh.tftpl", {
    aws_account_id                 = data.aws_caller_identity.current.account_id
    aws_region                     = data.aws_region.current.region
    cloudwatch_agent_parameter     = local.cloudwatch_agent_parameter_names.web
    cloudwatch_log_group           = local.log_group_names.web.application
    cloudwatch_bootstrap_log_group = local.log_group_names.web.bootstrap
    cloudwatch_log_retention_days  = var.cloudwatch_log_retention_days
    container_name                 = var.frontend_container_name
    health_check_attempts          = var.container_health_check_attempts
    health_check_interval_seconds  = var.container_health_check_interval_seconds
    environment                    = var.environment
    ecr_repository                 = var.ecr_repository_name
    image_tag_parameter_name       = aws_ssm_parameter.image_tag["web"].name
    internal_alb_dns_name          = var.internal_alb_dns_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-web"
      Tier = "web"
    })
  }

  tags = local.common_tags
}

resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-app-"
  image_id      = data.aws_ami.custom.id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2["app"].arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data/app.sh.tftpl", {
    app_port                       = var.app_port
    aws_account_id                 = data.aws_caller_identity.current.account_id
    aws_region                     = data.aws_region.current.region
    backend_log_level              = var.backend_log_level
    cloudwatch_agent_parameter     = local.cloudwatch_agent_parameter_names.app
    cloudwatch_log_group           = local.log_group_names.app.application
    cloudwatch_bootstrap_log_group = local.log_group_names.app.bootstrap
    cloudwatch_log_retention_days  = var.cloudwatch_log_retention_days
    container_name                 = var.backend_container_name
    database_url_parameter_name    = local.database_url_parameter_name
    environment                    = var.environment
    ecr_repository                 = var.ecr_repository_name
    gunicorn_threads               = var.backend_gunicorn_threads
    gunicorn_workers               = var.backend_gunicorn_workers
    health_check_attempts          = var.container_health_check_attempts
    health_check_interval_seconds  = var.container_health_check_interval_seconds
    image_tag_parameter_name       = aws_ssm_parameter.image_tag["app"].name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-app"
      Tier = "app"
    })
  }

  tags = local.common_tags
}

resource "aws_autoscaling_group" "web" {
  name                = "${local.name_prefix}-web-asg"
  desired_capacity    = var.web_desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.web_subnet_ids
  target_group_arns   = [var.web_target_group_arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${local.name_prefix}-web" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "${local.name_prefix}-app-asg"
  desired_capacity    = var.app_desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.app_subnet_ids
  target_group_arns   = [var.app_target_group_arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${local.name_prefix}-app" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
