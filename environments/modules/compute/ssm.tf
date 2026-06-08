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
