# GitHub Actions IAM Module

Creates GitHub OIDC IAM roles and policies for Terraform plan/apply and application deployment workflows.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.49.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.app_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.app_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.app_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_deployment_app_ssm_prefix"></a> [deployment\_app\_ssm\_prefix](#input\_deployment\_app\_ssm\_prefix) | SSM Parameter Store prefix used by application deployment image tag parameters. | `string` | `null` | no |
| <a name="input_dev_state_key"></a> [dev\_state\_key](#input\_dev\_state\_key) | S3 object key for the dev Terraform state file. | `string` | n/a | yes |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | ECR repository name that the application deployment role can push to. | `string` | `"deployments-notes-app"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name used for IAM role and policy names. | `string` | n/a | yes |
| <a name="input_github_app_environment"></a> [github\_app\_environment](#input\_github\_app\_environment) | GitHub Environment name allowed to assume the application deployment role. | `string` | `"app-dev"` | no |
| <a name="input_github_environment"></a> [github\_environment](#input\_github\_environment) | GitHub Environment name allowed to assume the Terraform apply role. | `string` | `"terraform-dev"` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | GitHub repository in owner/name format | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name used for IAM role and policy names. | `string` | n/a | yes |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | S3 bucket name containing Terraform remote state. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_app_deploy_permission_policy_json"></a> [app\_deploy\_permission\_policy\_json](#output\_app\_deploy\_permission\_policy\_json) | Rendered permissions policy JSON for the application deployment role. |
| <a name="output_app_deploy_policy_arn"></a> [app\_deploy\_policy\_arn](#output\_app\_deploy\_policy\_arn) | ARN of the application deployment permissions policy. |
| <a name="output_app_deploy_role_arn"></a> [app\_deploy\_role\_arn](#output\_app\_deploy\_role\_arn) | ARN of the application deployment role. |
| <a name="output_app_deploy_trust_policy_json"></a> [app\_deploy\_trust\_policy\_json](#output\_app\_deploy\_trust\_policy\_json) | Rendered trust policy JSON for the application deployment role. |
| <a name="output_apply_permission_policy_json"></a> [apply\_permission\_policy\_json](#output\_apply\_permission\_policy\_json) | Rendered permissions policy JSON for the Terraform apply role. |
| <a name="output_apply_policy_arn"></a> [apply\_policy\_arn](#output\_apply\_policy\_arn) | ARN of the Terraform apply permissions policy. |
| <a name="output_apply_role_arn"></a> [apply\_role\_arn](#output\_apply\_role\_arn) | ARN of the Terraform apply role. |
| <a name="output_apply_trust_policy_json"></a> [apply\_trust\_policy\_json](#output\_apply\_trust\_policy\_json) | Rendered trust policy JSON for the Terraform apply role. |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the existing GitHub Actions OIDC provider. |
| <a name="output_plan_permission_policy_json"></a> [plan\_permission\_policy\_json](#output\_plan\_permission\_policy\_json) | Rendered permissions policy JSON for the Terraform plan role. |
| <a name="output_plan_policy_arn"></a> [plan\_policy\_arn](#output\_plan\_policy\_arn) | ARN of the Terraform plan permissions policy. |
| <a name="output_plan_role_arn"></a> [plan\_role\_arn](#output\_plan\_role\_arn) | ARN of the Terraform plan role. |
| <a name="output_plan_trust_policy_json"></a> [plan\_trust\_policy\_json](#output\_plan\_trust\_policy\_json) | Rendered trust policy JSON for the Terraform plan role. |
<!-- END_TF_DOCS -->
