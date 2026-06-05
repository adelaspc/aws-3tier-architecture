output "public_fqdn" {
  value = "${cloudflare_dns_record.public_app.name}.${var.public_zone_name}"
}

output "private_fqdn" {
  value = aws_route53_record.private_api.fqdn
}
