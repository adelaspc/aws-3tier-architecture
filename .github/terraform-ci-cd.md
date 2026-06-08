# Terraform CI/CD setup

The workflow in `workflows/terraform-ci-cd.yml` validates all Terraform code,
runs TFLint and Checkov, and creates plans for pull requests. Infrastructure
changes are applied only through a manual `workflow_dispatch` run with the
`apply` operation, after approval through the `terraform-dev` environment.
Intentional Checkov exceptions are documented inline next to the affected
Terraform resources; any other finding fails the workflow.

## Repository variables

- `AWS_REGION`: AWS region used by the dev stack, for example `eu-central-1`.
- `AWS_TERRAFORM_ROLE_ARN`: IAM role assumed by GitHub Actions through OIDC.
- `TF_STATE_BUCKET`: existing remote-state S3 bucket.
- `TF_STATE_KEY`: state object key, for example
  `aws-3tier-architecture/dev/terraform.tfstate`.
- `TF_STATE_LOCK_TABLE`: existing DynamoDB lock table.

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
gate applies. The IAM role trust policy must allow the repository's OIDC
subjects used by pull-request plans and by the `terraform-dev` environment.
Restrict the role to this repository and grant only the AWS permissions needed
by the Terraform stack and remote-state backend.
