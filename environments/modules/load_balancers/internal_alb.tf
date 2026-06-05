resource "aws_lb" "internal" {
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
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
