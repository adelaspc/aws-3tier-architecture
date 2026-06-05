data "aws_acm_certificate" "app" {
  count = var.acm_certificate_arn == null ? 1 : 0

  domain      = var.certificate_domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

locals {
  certificate_arn = var.acm_certificate_arn != null ? var.acm_certificate_arn : data.aws_acm_certificate.app[0].arn
}

resource "aws_lb" "public_lb" {
  name               = "${local.name_prefix}-public-alb"
  internal           = false
  load_balancer_type = "application"

  subnets         = var.public_subnet_ids
  security_groups = [var.public_alb_sg_id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-alb"
  })
}

resource "aws_lb_target_group" "web" {
  name     = "${local.name_prefix}-web-tg"
  port     = var.web_target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.web_health_check_path
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-tg"
  })
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "public_https" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = local.certificate_arn
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
