resource "aws_security_group" "public_alb" {
  #checkov:skip=CKV2_AWS_5: Security group attachment occurs in the load_balancers module
  name        = "${local.name_prefix}-sg-public-alb"
  description = "Security group for public ALB"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg-public-alb"
  })
}

resource "aws_security_group" "internal_alb" {
  #checkov:skip=CKV2_AWS_5: Security group attachment occurs in the load_balancers module
  name        = "${local.name_prefix}-sg-internal-alb"
  description = "Security group for internal alb"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg-internal-alb"
  })

}

resource "aws_security_group" "web_ec2" {
  #checkov:skip=CKV2_AWS_5: Security group attachment occurs in the compute module
  name        = "${local.name_prefix}-sg-web"
  description = "Security group for web EC2 instances "
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg-web-ec2"
  })
}

resource "aws_security_group" "app_ec2" {
  #checkov:skip=CKV2_AWS_5: Security group attachment occurs in the compute module
  name        = "${local.name_prefix}-sg-app"
  description = "Security group for app EC2 instances"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg-app-ec2"
  })
}

resource "aws_security_group" "db" {
  #checkov:skip=CKV2_AWS_5: Security group attachment occurs in the rds module
  name        = "${local.name_prefix}-sg-db"
  description = "Security group for database instances"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg-db"
  })
}

resource "aws_vpc_security_group_ingress_rule" "public_alb_http" {
  #checkov:skip=CKV_AWS_260: Port 80 is exposed only to redirect public HTTP requests to HTTPS
  security_group_id = aws_security_group.public_alb.id
  description       = "Allow HTTP from the internet"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "public_alb_https" {
  security_group_id = aws_security_group.public_alb.id
  description       = "Allow HTTPS from the internet"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "public_alb_to_web_http" {
  security_group_id            = aws_security_group.public_alb.id
  description                  = "Allow HTTP traffic to web EC2 instances"
  from_port                    = var.web_port
  ip_protocol                  = "tcp"
  to_port                      = var.web_port
  referenced_security_group_id = aws_security_group.web_ec2.id
}

resource "aws_vpc_security_group_ingress_rule" "web_from_public_alb" {
  #checkov:skip=CKV_AWS_260: Source is a referenced security group, not an unrestricted IPv4 CIDR
  security_group_id = aws_security_group.web_ec2.id

  description = "Allow traffic from public ALB"

  ip_protocol                  = "tcp"
  from_port                    = var.web_port
  to_port                      = var.web_port
  referenced_security_group_id = aws_security_group.public_alb.id
}


resource "aws_vpc_security_group_egress_rule" "web_to_https_internet" {
  security_group_id = aws_security_group.web_ec2.id

  description = "Allow HTTPS outbound for SSM, ECR, CloudWatch and AWS APIs"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_to_internal_alb" {
  security_group_id = aws_security_group.web_ec2.id

  description = "Allow traffic to internal ALB from web EC2"

  ip_protocol                  = "tcp"
  from_port                    = var.web_port
  to_port                      = var.web_port
  referenced_security_group_id = aws_security_group.internal_alb.id
}


resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_web" {
  #checkov:skip=CKV_AWS_260: Source is a referenced security group, not an unrestricted IPv4 CIDR
  security_group_id            = aws_security_group.internal_alb.id
  description                  = "Allow HTTP from web EC2 instances"
  from_port                    = var.web_port
  ip_protocol                  = "tcp"
  to_port                      = var.web_port
  referenced_security_group_id = aws_security_group.web_ec2.id
}

resource "aws_vpc_security_group_egress_rule" "internal_alb_to_app" {
  security_group_id            = aws_security_group.internal_alb.id
  description                  = "Allow HTTP to app EC2 instances"
  from_port                    = var.app_port
  ip_protocol                  = "tcp"
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.app_ec2.id
}

resource "aws_vpc_security_group_ingress_rule" "app_ec2_from_internal_alb" {
  security_group_id            = aws_security_group.app_ec2.id
  description                  = "Allow HTTP from internal ALB"
  from_port                    = var.app_port
  ip_protocol                  = "tcp"
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.internal_alb.id
}

resource "aws_vpc_security_group_egress_rule" "app_to_internet" {
  security_group_id = aws_security_group.app_ec2.id

  description = "Allow HTTPS outbound for SSM, ECR, CloudWatch and AWS API"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id = aws_security_group.app_ec2.id

  description = "Allow traffic from app EC2 to DB"

  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.db.id
}


resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id = aws_security_group.db.id

  description = "Allow traffic form app EC2 to DB"

  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.app_ec2.id
}
