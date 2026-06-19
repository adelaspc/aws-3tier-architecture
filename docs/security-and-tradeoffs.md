# Security and Trade-offs

This project is a portfolio demo, not a production baseline. It intentionally balances realistic architecture, low cost, and clean teardown.

## Security Controls Included

- Private subnets for web, app, and database tiers.
- Public access limited to the internet-facing ALB.
- Security-group based tier boundaries.
- RDS is not publicly accessible.
- RDS storage encryption is enabled.
- RDS master password is managed by AWS.
- Terraform state is stored in S3 with encryption and versioning.
- GitHub Actions uses OIDC instead of static AWS access keys.
- Terraform plan, apply, and app deployment use separate IAM roles.

## Ephemeral Demo Trade-offs

The expected workflow is to create the stack, verify it, and destroy it. Because the environment is not intended to retain production data, several settings favor cleanup and cost control:

- RDS deletion protection is disabled by default.
- Final RDS snapshots are skipped by default.
- ALB deletion protection is disabled.
- Some observability features are omitted by default.
- CloudWatch log retention is short.

For a production-like profile, set `db_deletion_protection = true`, `db_skip_final_snapshot = false`, choose a `db_final_snapshot_identifier`, set `db_apply_immediately = false`, review `db_backup_retention_period`, enable centralized logging, and define a tested restore process.

## Cost Trade-offs

Cost-conscious choices:

- Small EC2 and RDS defaults.
- Short log retention.
- ALB access logs supported but disabled by default.
- No VPC Flow Logs by default.
- Manual teardown expected after validation.

Higher-availability choices that increase cost:

- Multi-AZ subnets.
- Multiple NAT gateways.
- Separate public and internal ALBs.
- ASGs in more than one AZ.
- RDS Multi-AZ support.

## NAT Gateway vs VPC Endpoints

The web and app private subnets use NAT gateways for outbound access to AWS services such as SSM, ECR, and CloudWatch. This was chosen for ease of use in a demo environment: instances can reach the required AWS APIs without managing several service-specific VPC endpoints and endpoint security group rules.

The trade-off is cost. NAT gateways are a meaningful recurring charge while the stack is running, especially with one NAT gateway per Availability Zone. For a longer-lived or production environment, consider adding VPC endpoints for services such as SSM, EC2 messages, SSM messages, ECR API, ECR Docker, CloudWatch Logs, and S3. That would reduce NAT dependency for AWS service traffic, but it adds more Terraform resources and operational detail.

## ALB Access Logs

ALB access logs are supported but disabled by default in the demo environment to keep costs and storage usage low.

When enabled, logs are delivered to an S3 bucket with public access blocked, server-side encryption, and lifecycle expiration. This is useful for request-level debugging, traffic analysis, and basic auditability.

Trade-off:

- Disabled by default: lower cost and simpler demo setup.
- Enabled when needed: better observability and troubleshooting capability.

## AWS-Managed KMS Keys

This demo uses AWS-managed encryption keys for RDS managed secrets and SSM Parameter Store values instead of customer-managed KMS keys. That keeps the IAM model and teardown process simpler for a short-lived portfolio environment.

Trade-off:

- AWS-managed keys: less Terraform and IAM complexity, no custom key rotation policy to operate.
- Customer-managed keys: stronger control and audit boundaries for production, but require explicit key policies, rotation decisions, and additional runtime `kms:Decrypt` permissions.

## Checkov Exceptions

Some Checkov findings are intentionally skipped inline in Terraform. These skips should be read as documented demo trade-offs, not production recommendations.

Common categories:

- Logging omitted to reduce demo cost.
- Optional ALB access logs disabled by default for the demo environment.
- Deletion protection disabled for clean destroy.
- RDS Performance Insights is not enabled by default. AWS provides a no-charge short retention window today, but longer retention or advanced database observability can add cost and operational surface area. A production profile should enable the appropriate RDS or CloudWatch Database Insights settings intentionally.
- Internal HTTP accepted inside private subnets with security group restrictions.
- WAF omitted to avoid cost and operational overhead for a temporary demo.

## Runtime SSM Parameters

Some runtime parameters are manually created for the current demo. This keeps the infrastructure code focused and avoids storing some sensitive runtime values in Terraform state. The trade-off is that first boot depends on correct manual parameter setup.

Future improvement: formalize this with a documented bootstrap script or a Terraform pattern that avoids exposing sensitive values unnecessarily.
