resource "aws_ssm_parameter" "image_tag" {
  #checkov:skip=CKV2_AWS_34: Container image tags are deployment metadata and contain no secrets
  for_each = {
    app = var.initial_backend_image_tag
    web = var.initial_frontend_image_tag
  }

  name  = local.image_tag_parameter_names[each.key]
  type  = "String"
  value = each.value
  tags  = local.common_tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "database_config" {
  #checkov:skip=CKV2_AWS_34: This parameter contains non-secret DB metadata; the password remains in Secrets Manager
  name = local.database_config_parameter_name
  type = "String"
  value = jsonencode({
    host       = var.database_host
    port       = var.database_port
    database   = var.database_name
    username   = var.database_username
    secret_arn = var.database_secret_arn
  })
  tags = local.common_tags
}
