# Compute Module

Creates EC2 Launch Templates, Auto Scaling Groups, EC2 IAM roles, and SSM image tag parameters for the web and app tiers.

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
| [aws_autoscaling_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_group.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_launch_template.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ssm_parameter.database_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.image_tag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_desired_capacity"></a> [app\_desired\_capacity](#input\_app\_desired\_capacity) | Desired capacity for the app Auto Scaling Group. | `number` | `2` | no |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | Port exposed by the backend application container. | `number` | `5000` | no |
| <a name="input_app_security_group_id"></a> [app\_security\_group\_id](#input\_app\_security\_group\_id) | Security group ID attached to app EC2 instances. | `string` | n/a | yes |
| <a name="input_app_subnet_ids"></a> [app\_subnet\_ids](#input\_app\_subnet\_ids) | Subnet IDs used by the app Auto Scaling Group. | `list(string)` | n/a | yes |
| <a name="input_app_target_group_arn"></a> [app\_target\_group\_arn](#input\_app\_target\_group\_arn) | Target group ARN where app instances register. | `string` | n/a | yes |
| <a name="input_backend_container_name"></a> [backend\_container\_name](#input\_backend\_container\_name) | Docker container name for the backend service. | `string` | `"deployment-notes-backend"` | no |
| <a name="input_backend_gunicorn_threads"></a> [backend\_gunicorn\_threads](#input\_backend\_gunicorn\_threads) | Number of Gunicorn threads per backend worker. | `number` | `4` | no |
| <a name="input_backend_gunicorn_workers"></a> [backend\_gunicorn\_workers](#input\_backend\_gunicorn\_workers) | Number of Gunicorn worker processes for the backend container. | `number` | `2` | no |
| <a name="input_backend_log_level"></a> [backend\_log\_level](#input\_backend\_log\_level) | Log level passed to the backend container. | `string` | `"INFO"` | no |
| <a name="input_cloudwatch_log_group_prefix"></a> [cloudwatch\_log\_group\_prefix](#input\_cloudwatch\_log\_group\_prefix) | CloudWatch Logs prefix for application and bootstrap logs | `string` | `null` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Number of days to retain CloudWatch log groups created by instance bootstrap. | `number` | `7` | no |
| <a name="input_container_health_check_attempts"></a> [container\_health\_check\_attempts](#input\_container\_health\_check\_attempts) | Number of local container health check attempts during EC2 bootstrap. | `number` | `10` | no |
| <a name="input_container_health_check_interval_seconds"></a> [container\_health\_check\_interval\_seconds](#input\_container\_health\_check\_interval\_seconds) | Seconds to wait between local container health check attempts during EC2 bootstrap. | `number` | `3` | no |
| <a name="input_custom_ami_id"></a> [custom\_ami\_id](#input\_custom\_ami\_id) | ID of the custom baked AMI used by web and app instances | `string` | n/a | yes |
| <a name="input_database_host"></a> [database\_host](#input\_database\_host) | RDS database hostname used by the backend application. | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Database name used by the backend application. | `string` | n/a | yes |
| <a name="input_database_port"></a> [database\_port](#input\_database\_port) | RDS database port used by the backend application. | `number` | `3306` | no |
| <a name="input_database_secret_arn"></a> [database\_secret\_arn](#input\_database\_secret\_arn) | ARN of the AWS-managed RDS master user secret used by the backend application. | `string` | n/a | yes |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | Database username stored in the backend runtime DB config parameter. | `string` | n/a | yes |
| <a name="input_deployment_app_ssm_prefix"></a> [deployment\_app\_ssm\_prefix](#input\_deployment\_app\_ssm\_prefix) | SSM Parameter Store prefix used by the deployment-notes app | `string` | `null` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | Existing ECR repository containing frontend and backend images | `string` | `"deployments-notes-app"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name used for resource names and tags. | `string` | n/a | yes |
| <a name="input_frontend_container_name"></a> [frontend\_container\_name](#input\_frontend\_container\_name) | Docker container name for the frontend service. | `string` | `"deployment-notes-frontend"` | no |
| <a name="input_initial_backend_image_tag"></a> [initial\_backend\_image\_tag](#input\_initial\_backend\_image\_tag) | Initial backend image tag stored in SSM; application pipeline updates it later | `string` | `"backend-2.0.0"` | no |
| <a name="input_initial_frontend_image_tag"></a> [initial\_frontend\_image\_tag](#input\_initial\_frontend\_image\_tag) | Initial frontend image tag stored in SSM; application pipeline updates it later | `string` | `"frontend-2.0.1"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for web and app instances. | `string` | `"t3.micro"` | no |
| <a name="input_internal_alb_dns_name"></a> [internal\_alb\_dns\_name](#input\_internal\_alb\_dns\_name) | Private DNS name used by the web tier to reach the app tier. | `string` | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum size shared by the web and app Auto Scaling Groups. | `number` | `4` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum size shared by the web and app Auto Scaling Groups. | `number` | `2` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name used for resource names and tags. | `string` | n/a | yes |
| <a name="input_web_desired_capacity"></a> [web\_desired\_capacity](#input\_web\_desired\_capacity) | Desired capacity for the web Auto Scaling Group. | `number` | `2` | no |
| <a name="input_web_security_group_id"></a> [web\_security\_group\_id](#input\_web\_security\_group\_id) | Security group ID attached to web EC2 instances. | `string` | n/a | yes |
| <a name="input_web_subnet_ids"></a> [web\_subnet\_ids](#input\_web\_subnet\_ids) | Subnet IDs used by the web Auto Scaling Group. | `list(string)` | n/a | yes |
| <a name="input_web_target_group_arn"></a> [web\_target\_group\_arn](#input\_web\_target\_group\_arn) | Target group ARN where web instances register. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_app_asg_name"></a> [app\_asg\_name](#output\_app\_asg\_name) | Name of the app Auto Scaling Group. |
| <a name="output_backend_image_tag_parameter_name"></a> [backend\_image\_tag\_parameter\_name](#output\_backend\_image\_tag\_parameter\_name) | SSM parameter name containing the backend image tag. |
| <a name="output_database_config_parameter_name"></a> [database\_config\_parameter\_name](#output\_database\_config\_parameter\_name) | SSM parameter name containing non-secret database connection metadata. |
| <a name="output_frontend_image_tag_parameter_name"></a> [frontend\_image\_tag\_parameter\_name](#output\_frontend\_image\_tag\_parameter\_name) | SSM parameter name containing the frontend image tag. |
| <a name="output_web_asg_name"></a> [web\_asg\_name](#output\_web\_asg\_name) | Name of the web Auto Scaling Group. |
<!-- END_TF_DOCS -->
