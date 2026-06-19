# Dev Environment

Composes the reusable Terraform modules into the demo dev environment.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | Optional ARN of an existing ACM certificate covering the public domain | `string` | `null` | no |
| <a name="input_alb_access_logs"></a> [alb\_access\_logs](#input\_alb\_access\_logs) | ALB access log configuration. Disabled by default to reduce demo environment costs. | <pre>object({<br/>    enabled        = bool<br/>    bucket_name    = optional(string)<br/>    bucket_prefix  = optional(string, "alb-access-logs")<br/>    object_prefix  = optional(string, "alb")<br/>    retention_days = optional(number, 7)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_app_desired_capacity"></a> [app\_desired\_capacity](#input\_app\_desired\_capacity) | Desired capacity for the app Auto Scaling Group. | `number` | `2` | no |
| <a name="input_app_subnets"></a> [app\_subnets](#input\_app\_subnets) | CIDR blocks for private app-tier subnets, one per Availability Zone. | `list(string)` | n/a | yes |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability Zones used by the subnet layout. | `list(string)` | n/a | yes |
| <a name="input_backend_container_name"></a> [backend\_container\_name](#input\_backend\_container\_name) | Docker container name for the backend service. | `string` | `"deployment-notes-backend"` | no |
| <a name="input_backend_gunicorn_threads"></a> [backend\_gunicorn\_threads](#input\_backend\_gunicorn\_threads) | Number of Gunicorn threads per backend worker. | `number` | `4` | no |
| <a name="input_backend_gunicorn_workers"></a> [backend\_gunicorn\_workers](#input\_backend\_gunicorn\_workers) | Number of Gunicorn worker processes for the backend container. | `number` | `2` | no |
| <a name="input_backend_log_level"></a> [backend\_log\_level](#input\_backend\_log\_level) | Log level passed to the backend container. | `string` | `"INFO"` | no |
| <a name="input_cloudflare_proxied"></a> [cloudflare\_proxied](#input\_cloudflare\_proxied) | Whether Cloudflare should proxy traffic for the public application record | `bool` | `false` | no |
| <a name="input_cloudflare_zone_id"></a> [cloudflare\_zone\_id](#input\_cloudflare\_zone\_id) | Cloudflare zone ID for the public DNS zone | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group_prefix"></a> [cloudwatch\_log\_group\_prefix](#input\_cloudwatch\_log\_group\_prefix) | CloudWatch Logs prefix for application and bootstrap logs | `string` | `null` | no |
| <a name="input_container_health_check_attempts"></a> [container\_health\_check\_attempts](#input\_container\_health\_check\_attempts) | Number of local container health check attempts during EC2 bootstrap. | `number` | `10` | no |
| <a name="input_container_health_check_interval_seconds"></a> [container\_health\_check\_interval\_seconds](#input\_container\_health\_check\_interval\_seconds) | Seconds to wait between local container health check attempts during EC2 bootstrap. | `number` | `3` | no |
| <a name="input_custom_ami_id"></a> [custom\_ami\_id](#input\_custom\_ami\_id) | ID of the custom baked AMI used by web and app instances | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Initial database name created by RDS. | `string` | `"deployment_notes"` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | Initial allocated storage in GiB for the RDS instance. | `number` | `20` | no |
| <a name="input_db_apply_immediately"></a> [db\_apply\_immediately](#input\_db\_apply\_immediately) | Whether RDS modifications are applied immediately instead of during the next maintenance window. | `bool` | `true` | no |
| <a name="input_db_backup_retention_period"></a> [db\_backup\_retention\_period](#input\_db\_backup\_retention\_period) | Number of days to retain automated RDS backups. | `number` | `7` | no |
| <a name="input_db_deletion_protection"></a> [db\_deletion\_protection](#input\_db\_deletion\_protection) | Whether deletion protection is enabled for the RDS instance. | `bool` | `false` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | MySQL engine version for the RDS instance. | `string` | `"8.0"` | no |
| <a name="input_db_final_snapshot_identifier"></a> [db\_final\_snapshot\_identifier](#input\_db\_final\_snapshot\_identifier) | Optional final snapshot identifier used when db\_skip\_final\_snapshot is false. | `string` | `null` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | RDS instance class. | `string` | `"db.t3.micro"` | no |
| <a name="input_db_master_username"></a> [db\_master\_username](#input\_db\_master\_username) | Master username for the RDS instance. | `string` | `"rhaast"` | no |
| <a name="input_db_max_allocated_storage"></a> [db\_max\_allocated\_storage](#input\_db\_max\_allocated\_storage) | Upper storage autoscaling limit in GiB for the RDS instance. | `number` | `100` | no |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Whether to enable Multi-AZ deployment for RDS. | `bool` | `true` | no |
| <a name="input_db_skip_final_snapshot"></a> [db\_skip\_final\_snapshot](#input\_db\_skip\_final\_snapshot) | Whether to skip a final snapshot when destroying the RDS instance. | `bool` | `true` | no |
| <a name="input_db_storage_type"></a> [db\_storage\_type](#input\_db\_storage\_type) | Storage type for the RDS instance. | `string` | `"gp3"` | no |
| <a name="input_db_subnets"></a> [db\_subnets](#input\_db\_subnets) | CIDR blocks for isolated database subnets, one per Availability Zone. | `list(string)` | n/a | yes |
| <a name="input_deployment_app_ssm_prefix"></a> [deployment\_app\_ssm\_prefix](#input\_deployment\_app\_ssm\_prefix) | SSM Parameter Store prefix used by the deployment-notes app | `string` | `null` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | Existing ECR repository containing frontend and backend images | `string` | `"deployments-notes-app"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name used for resource names and tags. | `string` | n/a | yes |
| <a name="input_frontend_container_name"></a> [frontend\_container\_name](#input\_frontend\_container\_name) | Docker container name for the frontend service. | `string` | `"deployment-notes-frontend"` | no |
| <a name="input_initial_backend_image_tag"></a> [initial\_backend\_image\_tag](#input\_initial\_backend\_image\_tag) | Initial backend image tag stored in SSM; application pipeline updates it later | `string` | `"backend-2.0.0"` | no |
| <a name="input_initial_frontend_image_tag"></a> [initial\_frontend\_image\_tag](#input\_initial\_frontend\_image\_tag) | Initial frontend image tag stored in SSM; application pipeline updates it later | `string` | `"frontend-2.0.1"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for web and app instances. | `string` | `"t3.micro"` | no |
| <a name="input_private_zone_name"></a> [private\_zone\_name](#input\_private\_zone\_name) | Private Route 53 hosted zone name for internal API routing. | `string` | `"deployment-notes.internal"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name used for resource names and tags. | `string` | n/a | yes |
| <a name="input_public_record_name"></a> [public\_record\_name](#input\_public\_record\_name) | Cloudflare DNS record name for the public application | `string` | `"www"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | CIDR blocks for public subnets, one per Availability Zone. | `list(string)` | n/a | yes |
| <a name="input_public_zone_name"></a> [public\_zone\_name](#input\_public\_zone\_name) | Public DNS zone name used for the application hostname and ACM lookup. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region where the dev stack is deployed. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC. | `string` | n/a | yes |
| <a name="input_web_desired_capacity"></a> [web\_desired\_capacity](#input\_web\_desired\_capacity) | Desired capacity for the web Auto Scaling Group. | `number` | `2` | no |
| <a name="input_web_subnets"></a> [web\_subnets](#input\_web\_subnets) | CIDR blocks for private web-tier subnets, one per Availability Zone. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN of the ACM certificate used by the public HTTPS listener. |
| <a name="output_alb_access_logs_bucket_name"></a> [alb\_access\_logs\_bucket\_name](#output\_alb\_access\_logs\_bucket\_name) | Name of the ALB access logs bucket when access logs are enabled |
| <a name="output_app_asg_name"></a> [app\_asg\_name](#output\_app\_asg\_name) | Name of the app Auto Scaling Group. |
| <a name="output_backend_image_tag_parameter_name"></a> [backend\_image\_tag\_parameter\_name](#output\_backend\_image\_tag\_parameter\_name) | SSM parameter name containing the backend image tag. |
| <a name="output_database_config_parameter_name"></a> [database\_config\_parameter\_name](#output\_database\_config\_parameter\_name) | SSM parameter name containing non-secret database connection metadata. |
| <a name="output_frontend_image_tag_parameter_name"></a> [frontend\_image\_tag\_parameter\_name](#output\_frontend\_image\_tag\_parameter\_name) | SSM parameter name containing the frontend image tag. |
| <a name="output_github_actions_app_variables"></a> [github\_actions\_app\_variables](#output\_github\_actions\_app\_variables) | GitHub repository variables used by the application deployment workflow. |
| <a name="output_private_api_fqdn"></a> [private\_api\_fqdn](#output\_private\_api\_fqdn) | Private Route 53 hostname for the internal API. |
| <a name="output_public_application_url"></a> [public\_application\_url](#output\_public\_application\_url) | HTTPS URL for the public application. |
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | DNS address of the RDS instance. |
| <a name="output_rds_master_user_secret_arn"></a> [rds\_master\_user\_secret\_arn](#output\_rds\_master\_user\_secret\_arn) | ARN of the AWS-managed RDS master user secret. |
| <a name="output_web_asg_name"></a> [web\_asg\_name](#output\_web\_asg\_name) | Name of the web Auto Scaling Group. |
<!-- END_TF_DOCS -->
