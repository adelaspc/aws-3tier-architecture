# AWS Three-Tier Architecture with Terraform

[![Terraform CI/CD](https://github.com/adelaspc/aws-3tier-architecture/actions/workflows/terraform-ci-cd.yml/badge.svg)](https://github.com/adelaspc/aws-3tier-architecture/actions/workflows/terraform-ci-cd.yml)
[![App CI/CD](https://github.com/adelaspc/aws-3tier-architecture/actions/workflows/app-ci-cd.yml/badge.svg)](https://github.com/adelaspc/aws-3tier-architecture/actions/workflows/app-ci-cd.yml)
![Terraform](https://img.shields.io/badge/Terraform-1.15.6-844FBA?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Three--Tier%20Architecture-232F3E?logo=amazonwebservices&logoColor=white)
![Purpose](https://img.shields.io/badge/Purpose-Portfolio%20Demo-blue)

This repository provisions an AWS three-tier application environment with Terraform. It is designed as an ephemeral portfolio/demo stack: create the infrastructure, verify the architecture and deployment workflow, then destroy it to avoid ongoing AWS costs.

## Usage and Licensing

This repository is publicly visible for portfolio and evaluation purposes only. No license is granted to use, copy, modify, or distribute its contents. All rights are reserved by the copyright holder.

The sample workload is the `deployment-notes` application, a small Flask/Vue deployment tracking app deployed through EC2 Auto Scaling Groups, Application Load Balancers, Amazon RDS, ECR, SSM Parameter Store, and GitHub Actions. It is intentionally a simple demo application used to exercise the infrastructure and deployment workflow, not a production-ready product or a demonstration of application security design.

![Architecture diagram](Architecture.png)

## What This Project Demonstrates

- Modular Terraform for VPC, security groups, load balancers, compute, RDS, DNS, and GitHub Actions IAM.
- Multi-AZ AWS network layout with public, web, app, and database subnets.
- Public and internal Application Load Balancers.
- EC2 Launch Templates and Auto Scaling Groups for separate web and app tiers.
- Private RDS MySQL with encrypted storage and managed master password.
- S3 remote state bootstrap with native lockfile support.
- GitHub Actions OIDC roles for Terraform plan/apply and application deployment.
- Application releases through ECR images, SSM image tag parameters, database migrations, and ASG Instance Refresh.
- Explicit documentation of cost, security, and production-readiness trade-offs.

The application itself is documented separately in [deployment-notes/README.md](deployment-notes/README.md), including its intentionally limited demo scope.

## Quality Gates

The badges at the top of this README show the latest GitHub Actions status for the Terraform and application pipelines. The Terraform workflow checks formatting, generated module documentation, module tests, validation, TFLint, Checkov, and pull request plans. The application workflow runs tests, builds images, pushes to ECR, runs migrations, and refreshes the EC2 Auto Scaling Groups.

For a local pre-flight check before opening a pull request:

```bash
pre-commit run --all-files
```

## Architecture Summary

Traffic enters through Cloudflare DNS and an internet-facing ALB. The web tier runs a containerized Nginx/Vue frontend on EC2 instances in private subnets. API traffic is proxied to an internal ALB, which forwards requests to a Flask/Gunicorn app tier. The app tier connects to a private RDS MySQL database.

High-level flow:

```text
User
  -> Cloudflare DNS
  -> Public ALB
  -> Web ASG in private subnets
  -> Internal ALB
  -> App ASG in private subnets
  -> RDS MySQL in isolated database subnets
```

See [docs/architecture.md](docs/architecture.md) for more detail.

## Quick Start

Prerequisites:

- Terraform `1.15.6`.
- AWS account and local AWS credentials for initial bootstrap.
- Existing ACM certificate in the same AWS region as the public ALB, covering the public application hostname.
- Cloudflare zone and API token for public DNS. If Cloudflare proxying is enabled, verify ACM validation and ALB hostname behavior before relying on the proxied record.
- Existing GitHub OIDC provider in AWS for `token.actions.githubusercontent.com`.
- Existing ECR repository for backend/frontend images. This repository is intentionally treated as a prerequisite, not managed by this Terraform stack.
- Initial application images, or a plan to run the app deployment workflow after infrastructure is ready.
- Runtime SSM parameters for CloudWatch agent config. Database connection metadata is published by Terraform; see [docs/operations.md](docs/operations.md).

Bootstrap remote state:

```bash
cd environments/backend-bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Configure and apply the dev environment:

```bash
cd ../dev
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

When finished, destroy the demo stack to stop recurring charges:

```bash
terraform destroy
```

Keep the backend bootstrap stack separate from the dev stack so destroying the application does not delete the remote state bucket.

## GitHub Actions and CI/CD

The repository includes separate workflows for Terraform infrastructure and application deployments:

- Terraform CI/CD validates formatting and runs Terraform tests, TFLint, and Checkov; plans are manual.
- Manual Terraform apply is gated through a GitHub Environment.
- Application CI tests the backend and builds the frontend on pull requests and pushes.
- Manual application deployment builds Docker images, pushes to ECR, runs migrations through SSM, updates SSM image tag parameters, and triggers ASG Instance Refresh.

See [docs/ci-cd.md](docs/ci-cd.md) and [environments/github-actions-bootstrap/README.md](environments/github-actions-bootstrap/README.md).

## Deployment Workflow

Application deployment is intentionally separate from Terraform infrastructure changes. Terraform creates the shape of the infrastructure, while GitHub Actions controls image releases and instance replacement.

For application releases, the workflow updates backend/frontend image tag parameters in SSM Parameter Store and refreshes the web and app ASGs. For infrastructure changes that affect EC2 runtime configuration, run an Instance Refresh after `terraform apply`.

See [docs/demo-walkthrough.md](docs/demo-walkthrough.md) for an end-to-end reviewer flow and [docs/operations.md](docs/operations.md) for operational commands.

## Estimated Demo Cost

The infrastructure was cost-estimated using CloudCraft for the `eu-central-1` region. The estimate is intended as an approximate always-on development-environment cost, not a production billing guarantee.

![CloudCraft budget estimate](docs/assets/budget.png)

| Category | Resource | Count | Approx monthly cost |
|---|---|---:|---:|
| Compute | EC2 `t3.micro` Linux | 4 | $35.04 |
| Containers | ECR repository | 1 | $0.10 |
| Networking | Application Load Balancers | 2 | $51.10 |
| Networking | NAT Gateways | 2 | $76.96 |
| Database | RDS MySQL `db.t3.micro` Multi-AZ | 1 | $29.20 |
| **Total** |  |  | **$192.40/mo** |

Actual costs may vary based on traffic, data transfer, storage growth, logs, backups, enabled observability features, and regional pricing changes. The intended demo lifecycle is short: provision, verify, then destroy.

### Cost Optimization Options

For short-lived demos or lower-cost development environments:

- Use a single NAT Gateway, accepting reduced Availability Zone independence.
- Replace some NAT-dependent AWS service traffic with VPC endpoints for SSM, ECR, CloudWatch Logs, and S3.
- Disable RDS Multi-AZ for short-lived development environments.
- Scale web and app ASG desired capacity down to one instance per tier when high availability is not being tested.
- Destroy the environment when it is not actively being reviewed or tested.

## Cost-Conscious Choices

- Small default EC2 instance type.
- Small default RDS instance class.
- Short CloudWatch log retention.
- RDS deletion protection disabled by default for easy teardown.
- Final RDS snapshot skipped by default for disposable demo data.
- ALB access logs supported but disabled by default to reduce cost.
- VPC Flow Logs omitted by default to reduce cost.

These defaults are intentional for a portfolio demo and are not production recommendations.

## Intentional Trade-Offs

| Area | Demo choice | Production direction |
|---|---|---|
| Runtime secrets | RDS password is stored in the AWS-managed RDS master secret; Terraform publishes only non-secret DB metadata to SSM. | Keep secrets out of Terraform state and define a formal secrets bootstrap or rotation process. |
| Teardown safety | RDS deletion protection and final snapshot are disabled by default. | Enable deletion protection, final snapshots, and restore testing. |
| Network egress | Private subnets use NAT gateways for simpler AWS service access. | Add VPC endpoints for SSM, ECR, CloudWatch Logs, and S3 when the environment is long-lived. |
| Observability | Some optional logging and RDS Performance Insights are omitted by default. | Enable the appropriate logging, metrics, retention, alarms, and database observability profile. |
| Cost control | ALB access logs and VPC Flow Logs are disabled by default. | Enable audit logs with retention, lifecycle, and review processes. |

More detail: [docs/security-and-tradeoffs.md](docs/security-and-tradeoffs.md), including the runtime secrets and configuration flow, and [docs/decisions.md](docs/decisions.md).

## Higher-Availability Choices That Increase Cost

- Multi-AZ subnet layout.
- Web and app ASGs spread across multiple AZs.
- Two NAT gateways.
- Separate public and internal ALBs.
- RDS Multi-AZ support.

These choices make the architecture more realistic, but they increase the cost of leaving the stack running.

## Repository Structure

```text
.
|-- environments/
|   |-- backend-bootstrap/       # Remote state S3 bucket bootstrap
|   |-- github-actions-bootstrap/# GitHub OIDC IAM roles
|   |-- dev/                     # Composed dev environment
|   `-- modules/                 # Reusable Terraform modules
|-- deployment-notes/            # Sample Flask/Vue application
|-- .github/workflows/           # Terraform and app CI/CD workflows
|-- scripts/                     # Operational helper scripts
|-- docs/                        # Detailed architecture and operations docs
`-- Architecture.png             # Architecture diagram
```

## Documentation

- [Security policy](SECURITY.md)
- [Architecture](docs/architecture.md)
- [Infrastructure](docs/infrastructure.md)
- [Bootstrap](docs/bootstrap.md)
- [Demo walkthrough](docs/demo-walkthrough.md)
- [CI/CD](docs/ci-cd.md)
- [Operations](docs/operations.md)
- [Recovery](docs/recovery.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security and trade-offs](docs/security-and-tradeoffs.md)
- [Design decisions](docs/decisions.md)
- [Deployment Notes app](deployment-notes/README.md)
- Generated Terraform references:
  - [Dev environment](environments/dev/README.md)
  - [VPC module](environments/modules/vpc/README.md)
  - [Security groups module](environments/modules/security_groups/README.md)
  - [Load balancers module](environments/modules/load_balancers/README.md)
  - [Compute module](environments/modules/compute/README.md)
  - [RDS module](environments/modules/rds/README.md)
  - [DNS module](environments/modules/dns/README.md)
  - [GitHub Actions IAM module](environments/modules/github-actions-iam/README.md)

## Current Limitations

- This is an ephemeral demo stack, not a production environment.
- Runtime SSM parameters for CloudWatch agent configuration are created manually.
- The ECR repository is expected to exist before deployment and is not created by Terraform.
- The public application requires an existing ACM certificate.
- The app deployment workflow assumes GitHub variables and environments are configured after IAM bootstrap.
- Some logging, backup, and retention controls are relaxed to keep teardown simple and cost low.

## Future Improvements

- Terraform-managed CloudWatch agent SSM bootstrap.
- Optional VPC endpoints for SSM, ECR, CloudWatch Logs, and S3.
- Optional VPC Flow Logs.
- Infracost estimate and cost examples by region.
- Source file for the architecture diagram.
- Additional environment separation for staging or production-style deployments.
