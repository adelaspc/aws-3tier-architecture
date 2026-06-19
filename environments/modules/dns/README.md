# DNS Module

Creates the Cloudflare public DNS record and Route 53 private hosted zone record.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_route53_record.private_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [cloudflare_dns_record.public_app](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloudflare_proxied"></a> [cloudflare\_proxied](#input\_cloudflare\_proxied) | Whether Cloudflare should proxy the public application record. | `bool` | `false` | no |
| <a name="input_cloudflare_zone_id"></a> [cloudflare\_zone\_id](#input\_cloudflare\_zone\_id) | Cloudflare zone ID where the public application record is managed. | `string` | n/a | yes |
| <a name="input_internal_alb_dns_name"></a> [internal\_alb\_dns\_name](#input\_internal\_alb\_dns\_name) | DNS name of the internal ALB. | `string` | n/a | yes |
| <a name="input_internal_alb_zone_id"></a> [internal\_alb\_zone\_id](#input\_internal\_alb\_zone\_id) | Route 53 zone ID of the internal ALB for alias records. | `string` | n/a | yes |
| <a name="input_private_record_name"></a> [private\_record\_name](#input\_private\_record\_name) | Private DNS record name pointing to the internal ALB. | `string` | `"api"` | no |
| <a name="input_private_zone_name"></a> [private\_zone\_name](#input\_private\_zone\_name) | Private Route 53 hosted zone name. | `string` | `"deployment-notes.internal"` | no |
| <a name="input_public_alb_dns_name"></a> [public\_alb\_dns\_name](#input\_public\_alb\_dns\_name) | DNS name of the public ALB used as the Cloudflare CNAME target. | `string` | n/a | yes |
| <a name="input_public_record_name"></a> [public\_record\_name](#input\_public\_record\_name) | Cloudflare DNS record name for the public application. | `string` | n/a | yes |
| <a name="input_public_zone_name"></a> [public\_zone\_name](#input\_public\_zone\_name) | Public DNS zone name used to build the application FQDN. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID associated with the private hosted zone. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_private_fqdn"></a> [private\_fqdn](#output\_private\_fqdn) | Fully qualified private API hostname. |
| <a name="output_public_fqdn"></a> [public\_fqdn](#output\_public\_fqdn) | Fully qualified public application hostname. |
<!-- END_TF_DOCS -->
