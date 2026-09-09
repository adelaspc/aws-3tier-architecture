# Bootstrap

This repository has two bootstrap paths:

- Terraform remote state bootstrap.
- GitHub Actions IAM bootstrap.

Both are intentionally separate from the main `dev` environment so the application stack can be destroyed without deleting its state backend or CI identities.

## Remote State Bootstrap

The backend bootstrap creates the S3 bucket used by the dev Terraform backend.

```bash
cd environments/backend-bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Use the outputs to populate `environments/dev/backend.hcl` from `backend.hcl.example`.

More detail: [../environments/backend-bootstrap/README.md](../environments/backend-bootstrap/README.md)

## GitHub Actions IAM Bootstrap

The GitHub Actions bootstrap creates IAM roles for:

- Terraform plan.
- Terraform apply.
- Application deployment.

It assumes the AWS account already has the GitHub OIDC provider for `token.actions.githubusercontent.com`.

```bash
cd environments/github-actions-bootstrap
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

Configure the outputs in GitHub repository or environment variables:

- `terraform_plan_role_arn` -> `AWS_TERRAFORM_PLAN_ROLE_ARN`
- `terraform_apply_role_arn` -> `AWS_TERRAFORM_APPLY_ROLE_ARN`
- `app_deploy_role_arn` -> `AWS_APP_DEPLOY_ROLE_ARN`

More detail: [../environments/github-actions-bootstrap/README.md](../environments/github-actions-bootstrap/README.md)

## Order of Operations

1. Bootstrap remote state.
2. Bootstrap GitHub Actions IAM.
3. Configure GitHub variables, secrets, and environments.
4. Configure `environments/dev` backend and variables.
5. Create the manually managed CloudWatch agent SSM parameters documented in [operations.md](operations.md).
6. Apply the dev infrastructure; Terraform creates the image-tag and non-secret database configuration parameters as part of this apply.
7. Configure GitHub application-deployment variables from the dev outputs.
8. Run the application deployment workflow.
