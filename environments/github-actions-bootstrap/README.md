# GitHub Actions IAM Bootstrap

This stack uses the account's existing GitHub OIDC provider and creates
separate Terraform plan/apply roles. It is intentionally separate from
`environments/dev`: the application stack must never manage the CI identities
that authorize its own workflow.

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

Create the `terraform-dev` GitHub Environment, restrict deployment branches to
`main`, and require reviewer approval. The workflow also checks `main`, but the
environment rule is an independent control.

The bootstrap state uses the existing state bucket with a dedicated key and S3
native lockfiles (`use_lockfile = true`).
