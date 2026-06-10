# Terraform CI/CD setup

The workflow in `workflows/terraform-ci-cd.yml` validates all Terraform code,
runs TFLint and Checkov, and creates plans for pull requests. Infrastructure
changes are applied only through a manual `workflow_dispatch` run with the
`apply` operation, after approval through the `terraform-dev` environment.
Intentional Checkov exceptions are documented inline next to the affected
Terraform resources; any other finding fails the workflow.

## Repository variables

- `AWS_REGION`: AWS region used by the dev stack, for example `eu-central-1`.
- `AWS_TERRAFORM_PLAN_ROLE_ARN`: read-only infrastructure role used by plans.
- `AWS_TERRAFORM_APPLY_ROLE_ARN`: application lifecycle role used by manual applies.
- `TF_STATE_BUCKET`: existing remote-state S3 bucket.
- `TF_STATE_KEY`: state object key, for example
  `aws-3tier-architecture/dev/terraform.tfstate`.

## Repository secrets

- `CLOUDFLARE_API_TOKEN`: token allowed to manage DNS records in the target zone.
- `TF_VARS_JSON`: JSON object containing the values represented in
  `environments/dev/terraform.tfvars.example`.

Example `TF_VARS_JSON` shape:

```json
{
  "project": "project-name",
  "environment": "dev",
  "region": "eu-central-1",
  "vpc_cidr": "10.0.0.0/16",
  "azs": ["eu-central-1a", "eu-central-1b"],
  "public_subnets": ["10.0.0.0/27", "10.0.0.32/27"],
  "web_subnets": ["10.0.1.0/27", "10.0.1.32/27"],
  "app_subnets": ["10.0.2.0/27", "10.0.2.32/27"],
  "db_subnets": ["10.0.3.0/27", "10.0.3.32/27"],
  "public_zone_name": "example.com",
  "public_record_name": "www",
  "cloudflare_zone_id": "cloudflare-zone-id",
  "cloudflare_proxied": false,
  "acm_certificate_arn": "arn:aws:acm:eu-central-1:111122223333:certificate/example",
  "custom_ami_id": "ami-example",
  "ecr_repository_name": "deployment-notes-app",
  "initial_backend_image_tag": "backend-1.0.0",
  "initial_frontend_image_tag": "frontend-1.0.0"
}
```

## GitHub environment and AWS OIDC

Create the `terraform-dev` GitHub environment and add a required reviewer to
gate applies. Restrict its deployment branches to `main`. Apply runs must be
manually dispatched from `main`; the workflow and environment both enforce
that restriction.

Create the OIDC provider and both roles by applying
`environments/github-actions-bootstrap` with a trusted local AWS identity. The
plan role accepts internal pull requests and manual plans from repository
branches. Fork pull requests run quality checks but skip the AWS plan job. The
apply role accepts only the `terraform-dev` environment subject.

The bootstrap stack uses a state key separate from the dev application state.
DynamoDB locking is retained for now; migration to S3 native lockfiles is a
future improvement.
