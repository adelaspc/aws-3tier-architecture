resource "aws_lb" "internal" {
  #checkov:skip=CKV_AWS_91: Access logs are omitted to reduce cost for the short-lived demo
  #checkov:skip=CKV_AWS_131: Internal ALB only accepts traffic from the web-tier security group
  #checkov:skip=CKV_AWS_150: Deletion protection must remain disabled so terraform destroy can clean up the demo
  #checkov:skip=CKV2_AWS_20: Internal traffic uses HTTP inside private subnets and is restricted by security groups
  name               = "${local.name_prefix}-internal-alb"
  internal           = true
  load_balancer_type = "application"

  subnets         = var.app_subnet_ids
  security_groups = [var.internal_alb_sg_id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-internal-alb"
  })
}

resource "aws_lb_target_group" "app" {
  #checkov:skip=CKV_AWS_378: Backend HTTP is private VPC traffic restricted to the internal ALB security group
  name     = "${local.name_prefix}-app-tg"
  port     = var.app_target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.app_health_check_path
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-tg"
  })
}

resource "aws_lb_listener" "internal_http" {
  #checkov:skip=CKV_AWS_2: Internal listener is private and restricted to the web tier by security groups
  #checkov:skip=CKV_AWS_103: TLS policy is not applicable to the intentionally HTTP-only internal listener
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
