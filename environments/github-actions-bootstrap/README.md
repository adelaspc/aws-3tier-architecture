# GitHub Actions IAM Bootstrap

This stack uses the account's existing GitHub OIDC provider and creates
separate Terraform plan/apply roles plus an application deployment role. It is
intentionally separate from `environments/dev`: the application stack must
never manage the CI identities that authorize its own workflows.

Apply this stack initially with a trusted local AWS identity:

```bash
cd environments/github-actions-bootstrap
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

The GitHub OIDC provider for `token.actions.githubusercontent.com` must already
exist in the AWS account. This stack reads it as a data source and does not
modify or delete it.

Configure the outputs as GitHub repository variables:

- `terraform_plan_role_arn` -> `AWS_TERRAFORM_PLAN_ROLE_ARN`
- `terraform_apply_role_arn` -> `AWS_TERRAFORM_APPLY_ROLE_ARN`
- `app_deploy_role_arn` -> `AWS_APP_DEPLOY_ROLE_ARN`

For the complete variable set used by the workflows, read:

```bash
terraform output github_actions_repository_variables
```

Create the `terraform-dev` GitHub Environment, restrict deployment branches to
`main`, and require reviewer approval. The workflow also checks `main`, but the
environment rule is an independent control.

Create a separate `app-dev` GitHub Environment for application deployments,
also restricted to `main`. The application workflow must reference this
environment so its OIDC subject matches the app deployment role trust policy.

The bootstrap state uses the existing state bucket with a dedicated key and S3
native lockfiles (`use_lockfile = true`).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_deployment_app_ssm_prefix"></a> [deployment\_app\_ssm\_prefix](#input\_deployment\_app\_ssm\_prefix) | SSM Parameter Store prefix used by application deployment image tag parameters. | `string` | `null` | no |
| <a name="input_dev_state_key"></a> [dev\_state\_key](#input\_dev\_state\_key) | S3 object key for the dev Terraform state file. | `string` | `"aws-3tier-architecture/dev/terraform.tfstate"` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | ECR repository name that the application deployment role can push to. | `string` | `"deployments-notes-app"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name passed to the GitHub Actions IAM module. | `string` | n/a | yes |
| <a name="input_github_app_environment"></a> [github\_app\_environment](#input\_github\_app\_environment) | GitHub Environment name allowed to assume the application deployment role. | `string` | `"app-dev"` | no |
| <a name="input_github_environment"></a> [github\_environment](#input\_github\_environment) | GitHub Environment name allowed to assume the Terraform apply role. | `string` | `"terraform-dev"` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | GitHub repository in owner/name format allowed by OIDC trust policies. | `string` | `"adelaspc/aws-3tier-architecture"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name passed to the GitHub Actions IAM module. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region used by the bootstrap provider. | `string` | n/a | yes |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | S3 bucket name containing Terraform remote state. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_app_deploy_permission_policy_json"></a> [app\_deploy\_permission\_policy\_json](#output\_app\_deploy\_permission\_policy\_json) | Rendered permissions policy JSON for the application deployment role. |
| <a name="output_app_deploy_policy_arn"></a> [app\_deploy\_policy\_arn](#output\_app\_deploy\_policy\_arn) | ARN of the application deployment permissions policy. |
| <a name="output_app_deploy_role_arn"></a> [app\_deploy\_role\_arn](#output\_app\_deploy\_role\_arn) | ARN of the application deployment role. |
| <a name="output_app_deploy_trust_policy_json"></a> [app\_deploy\_trust\_policy\_json](#output\_app\_deploy\_trust\_policy\_json) | Rendered trust policy JSON for the application deployment role. |
| <a name="output_apply_permission_policy_json"></a> [apply\_permission\_policy\_json](#output\_apply\_permission\_policy\_json) | Rendered permissions policy JSON for the Terraform apply role. |
| <a name="output_apply_trust_policy_json"></a> [apply\_trust\_policy\_json](#output\_apply\_trust\_policy\_json) | Rendered trust policy JSON for the Terraform apply role. |
| <a name="output_github_actions_repository_variables"></a> [github\_actions\_repository\_variables](#output\_github\_actions\_repository\_variables) | GitHub repository variables used by the Terraform and application deployment workflows. |
| <a name="output_github_oidc_provider_arn"></a> [github\_oidc\_provider\_arn](#output\_github\_oidc\_provider\_arn) | ARN of the existing GitHub Actions OIDC provider. |
| <a name="output_plan_permission_policy_json"></a> [plan\_permission\_policy\_json](#output\_plan\_permission\_policy\_json) | Rendered permissions policy JSON for the Terraform plan role. |
| <a name="output_plan_trust_policy_json"></a> [plan\_trust\_policy\_json](#output\_plan\_trust\_policy\_json) | Rendered trust policy JSON for the Terraform plan role. |
| <a name="output_terraform_apply_policy_arn"></a> [terraform\_apply\_policy\_arn](#output\_terraform\_apply\_policy\_arn) | ARN of the Terraform apply permissions policy. |
| <a name="output_terraform_apply_role_arn"></a> [terraform\_apply\_role\_arn](#output\_terraform\_apply\_role\_arn) | ARN of the Terraform apply role. |
| <a name="output_terraform_plan_policy_arn"></a> [terraform\_plan\_policy\_arn](#output\_terraform\_plan\_policy\_arn) | ARN of the Terraform plan permissions policy. |
| <a name="output_terraform_plan_role_arn"></a> [terraform\_plan\_role\_arn](#output\_terraform\_plan\_role\_arn) | ARN of the Terraform plan role. |
<!-- END_TF_DOCS -->