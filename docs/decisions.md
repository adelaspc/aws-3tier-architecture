# Design Decisions

This document records key infrastructure decisions and their trade-offs.

## Use EC2 Auto Scaling Groups Instead of ECS

Decision: use EC2 Launch Templates and Auto Scaling Groups for the web and app tiers.

Why:

- Demonstrates EC2, Launch Templates, user data, ASGs, IAM instance profiles, and ALB target groups.
- Keeps infrastructure behavior explicit for learning and portfolio review.
- Shows how application deployment can be coordinated with SSM and Instance Refresh.

Trade-off:

- More operational responsibility than ECS.
- Application deployments must trigger ASG Instance Refresh to replace existing instances.

## Use Separate Public and Internal ALBs

Decision: expose the web tier through a public ALB and route API traffic through an internal ALB.

Why:

- Creates a clear public/private boundary.
- Demonstrates ALB-to-ASG integration for multiple tiers.
- Keeps the app tier private.

Trade-off:

- Adds cost compared with a single ALB.
- Adds more resources to configure and troubleshoot.

## Use GitHub OIDC Instead of Static AWS Keys

Decision: GitHub Actions assumes AWS IAM roles through OIDC.

Why:

- Avoids long-lived AWS credentials in GitHub secrets.
- Allows separate roles for plan, apply, and app deployment.
- Supports GitHub Environment gating for sensitive jobs.

Trade-off:

- Requires initial IAM bootstrap.
- Trust policy subjects must match GitHub repository and environment names exactly.

## Keep Runtime SSM Parameters Partly Manual

Decision: image tag parameters and non-secret database connection metadata are Terraform-managed, while CloudWatch agent config parameters are created manually for the demo.

Why:

- Keeps sensitive runtime values out of Terraform code and state.
- Avoids manually copying the RDS endpoint into a full database URL after RDS is created.
- Reflects the ephemeral nature of the demo.

Trade-off:

- First boot still depends on correct CloudWatch agent parameter setup.
- This must be documented clearly for repeatability.

## Use S3 Native Lockfiles for Terraform State

Decision: use S3 remote state with native lockfile support.

Why:

- Reduces bootstrap complexity.
- Avoids an extra DynamoDB table for this portfolio demo.
- Keeps state management easy to explain.

Trade-off:

- Requires a Terraform version that supports S3 lockfiles.

## Use NAT Gateways Instead of VPC Endpoints for AWS API Access

Decision: use NAT gateways for outbound access from private web and app subnets to AWS services such as SSM, ECR, and CloudWatch.

Why:

- Keeps the demo network simpler to understand and operate.
- Avoids managing multiple service-specific VPC endpoints and endpoint security group rules.
- Makes first deployment easier while still keeping EC2 instances in private subnets.

Trade-off:

- NAT gateways add recurring cost while the stack is running.
- A production or longer-lived environment should consider VPC endpoints for AWS service traffic.

## Pin Terraform and Track Provider Lockfiles

Decision: pin the Terraform CLI version with `.terraform-version`, declare compatible version constraints in Terraform, and commit provider lockfiles for initialized roots.

Why:

- Keeps local and CI behavior predictable.
- Makes provider upgrades explicit in pull requests.
- Allows patch/minor provider updates within selected major versions while avoiding unreviewed lockfile drift.

Trade-off:

- Multiple Terraform roots can have separate lockfiles.
- Provider upgrades require intentional `terraform init -upgrade` runs and review.

## Optimize for Ephemeral Demo Teardown

Decision: defaults favor clean `terraform destroy` over production retention.

Why:

- The stack is intended to be created, validated, and destroyed.
- Avoids unnecessary ongoing AWS cost.
- Keeps the project practical for a personal portfolio budget.

Trade-off:

- RDS final snapshots and deletion protection are not production-style defaults.
- Recovery guarantees are intentionally limited unless settings are changed.
