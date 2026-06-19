# Infrastructure

Terraform is organized around one composed environment and several reusable modules.

## Environments

- `environments/backend-bootstrap`: creates the S3 bucket used for Terraform remote state.
- `environments/github-actions-bootstrap`: creates GitHub Actions IAM roles for OIDC-based CI/CD.
- `environments/dev`: composes the application infrastructure modules.

## Modules

- `vpc`: VPC, subnets, internet gateway, NAT gateways, route tables, and DB subnet group.
- `security_groups`: tier-specific security groups and rules.
- `load_balancers`: public ALB, internal ALB, listeners, target groups, and optional ALB access log bucket.
- `compute`: EC2 Launch Templates, Auto Scaling Groups, IAM instance profiles, and SSM image tag parameters.
- `rds`: private RDS MySQL instance.
- `dns`: Cloudflare public DNS and Route 53 private DNS.
- `github-actions-iam`: GitHub OIDC IAM roles and policies.

## Terraform State

The dev environment uses an S3 backend with Terraform native lockfile support. The backend bucket is created separately so `terraform destroy` in the application environment does not delete the state bucket.

## Tagging Strategy

Terraform-managed resources use a consistent common tag set where supported:

- `Project`
- `Environment`
- `ManagedBy = terraform`
- `Owner = Adela`

Some resources add extra purpose or tier tags, such as `Name`, `Tier`, or `Purpose`. Consistent tags make AWS console filtering, cost review, and tools such as CloudCraft easier to use when the infrastructure is running.

## Terraform and Provider Versions

Terraform CLI version is pinned with `.terraform-version` and each root/module declares `required_version = "~> 1.15.0"`. Provider constraints are intentionally broad enough to allow compatible patch/minor updates within the selected major versions:

- AWS provider: `~> 6.0`
- Cloudflare provider: `~> 5.0`

Each independently initialized Terraform root keeps its own `.terraform.lock.hcl` file tracked in Git. Lockfiles make CI and local runs reproducible while still allowing intentional provider upgrades through `terraform init -upgrade` and a reviewed lockfile diff.

## Generated Terraform References

Module and environment references are generated with `terraform-docs` using `.terraform-docs.yml`. The generated sections live in each reusable module README and in `environments/dev/README.md`, keeping inputs, outputs, providers, requirements, and resources synchronized with the Terraform code.

Regenerate the references after changing variables, outputs, providers, or resources:

```bash
for module_dir in environments/modules/*; do
  [ -d "$module_dir" ] || continue
  terraform-docs --config .terraform-docs.yml "$module_dir"
done

terraform-docs --config .terraform-docs.yml environments/dev
```

## Runtime Configuration

The compute module manages image tag parameters and non-secret database connection metadata in SSM Parameter Store. The RDS password remains in the AWS-managed RDS master user secret. CloudWatch agent configuration parameters are still created manually for the demo and documented in operations guidance.

The ECR repository is intentionally not created by this Terraform stack. It is treated as a shared application delivery prerequisite, while Terraform receives the repository name through `ecr_repository_name` and grants the runtime/deployment permissions needed to pull or push images.

## Rollout Behavior

The web and app ASGs reference the latest Launch Template version. Terraform can create a new Launch Template version when AMI, user data, IAM instance profile, or instance type changes, but existing EC2 instances are not replaced automatically by that fact alone.

Application releases are rolled out through GitHub Actions by updating SSM image tag parameters and triggering ASG Instance Refresh. Infrastructure changes that affect EC2 runtime behavior should also be followed by Instance Refresh.
