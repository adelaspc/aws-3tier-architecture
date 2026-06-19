locals {
  public_zone_name_normalized   = trimsuffix(var.public_zone_name, ".")
  public_record_name_normalized = trimsuffix(var.public_record_name, ".")
  public_fqdn = local.public_record_name_normalized == "@" ? local.public_zone_name_normalized : (
    endswith(local.public_record_name_normalized, ".${local.public_zone_name_normalized}") ?
    local.public_record_name_normalized :
    "${local.public_record_name_normalized}.${local.public_zone_name_normalized}"
  )
}

output "public_fqdn" {
  description = "Fully qualified public application hostname."
  value       = local.public_fqdn
}

output "private_fqdn" {
  description = "Fully qualified private API hostname."
  value       = aws_route53_record.private_api.fqdn
}
