resource "cloudflare_dns_record" "public_app" {
  zone_id = var.cloudflare_zone_id
  name    = var.public_record_name
  type    = "CNAME"
  content = var.public_alb_dns_name
  ttl     = 1
  proxied = var.cloudflare_proxied
}

resource "aws_route53_zone" "private" {
  name = var.private_zone_name

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "private_api" {
  zone_id = aws_route53_zone.private.zone_id
  name    = var.private_record_name
  type    = "A"

  alias {
    name                   = var.internal_alb_dns_name
    zone_id                = var.internal_alb_zone_id
    evaluate_target_health = true
  }
}
