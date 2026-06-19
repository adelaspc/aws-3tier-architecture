# Load Balancers Module

Creates the public and internal Application Load Balancers, listeners, target groups, and optional ALB access log bucket.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_lb.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb.public_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.internal_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.public_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.public_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_s3_bucket.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.alb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | Optional explicit ARN of the existing ACM certificate | `string` | `null` | no |
| <a name="input_alb_access_logs"></a> [alb\_access\_logs](#input\_alb\_access\_logs) | ALB access log configuration. Disabled by default to reduce demo environment costs. | <pre>object({<br/>    enabled        = bool<br/>    bucket_name    = optional(string)<br/>    bucket_prefix  = optional(string, "alb-access-logs")<br/>    object_prefix  = optional(string, "alb")<br/>    retention_days = optional(number, 7)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_app_health_check_path"></a> [app\_health\_check\_path](#input\_app\_health\_check\_path) | HTTP health check path for the app target group. | `string` | `"/health"` | no |
| <a name="input_app_subnet_ids"></a> [app\_subnet\_ids](#input\_app\_subnet\_ids) | Subnet IDs for the internal ALB. | `list(string)` | n/a | yes |
| <a name="input_app_target_port"></a> [app\_target\_port](#input\_app\_target\_port) | Port used by the internal ALB target group for app instances. | `number` | `5000` | no |
| <a name="input_certificate_domain_name"></a> [certificate\_domain\_name](#input\_certificate\_domain\_name) | Primary domain name of the existing ACM certificate | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name used for resource names and tags. | `string` | n/a | yes |
| <a name="input_internal_alb_sg_id"></a> [internal\_alb\_sg\_id](#input\_internal\_alb\_sg\_id) | Security group ID attached to the internal ALB. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name used for resource names and tags. | `string` | n/a | yes |
| <a name="input_public_alb_sg_id"></a> [public\_alb\_sg\_id](#input\_public\_alb\_sg\_id) | Security group ID attached to the public ALB. | `string` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Subnet IDs for the internet-facing public ALB. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where load balancers and target groups are created. | `string` | n/a | yes |
| <a name="input_web_health_check_path"></a> [web\_health\_check\_path](#input\_web\_health\_check\_path) | HTTP health check path for the web target group. | `string` | `"/"` | no |
| <a name="input_web_target_port"></a> [web\_target\_port](#input\_web\_target\_port) | Port used by the public ALB target group for web instances. | `number` | `80` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN of the ACM certificate used by the public HTTPS listener. |
| <a name="output_alb_access_logs_bucket_name"></a> [alb\_access\_logs\_bucket\_name](#output\_alb\_access\_logs\_bucket\_name) | Name of the ALB access logs bucket when access logs are enabled |
| <a name="output_internal_alb_arn"></a> [internal\_alb\_arn](#output\_internal\_alb\_arn) | ARN of the internal ALB. |
| <a name="output_internal_alb_dns_name"></a> [internal\_alb\_dns\_name](#output\_internal\_alb\_dns\_name) | DNS name of the internal ALB. |
| <a name="output_internal_alb_zone_id"></a> [internal\_alb\_zone\_id](#output\_internal\_alb\_zone\_id) | Route 53 zone ID of the internal ALB. |
| <a name="output_internal_app_target_group_arn"></a> [internal\_app\_target\_group\_arn](#output\_internal\_app\_target\_group\_arn) | ARN of the internal app target group. |
| <a name="output_public_alb_arn"></a> [public\_alb\_arn](#output\_public\_alb\_arn) | ARN of the public ALB. |
| <a name="output_public_alb_dns_name"></a> [public\_alb\_dns\_name](#output\_public\_alb\_dns\_name) | DNS name of the public ALB. |
| <a name="output_public_web_target_group_arn"></a> [public\_web\_target\_group\_arn](#output\_public\_web\_target\_group\_arn) | ARN of the public web target group. |
<!-- END_TF_DOCS -->
