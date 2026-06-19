# Demo Walkthrough

This walkthrough is the shortest path for a reviewer to understand, deploy, verify, and destroy the portfolio environment.

## 1. Review the Architecture

Start with:

- [README.md](../README.md)
- [architecture.md](architecture.md)
- [security-and-tradeoffs.md](security-and-tradeoffs.md)
- [decisions.md](decisions.md)

The stack provisions a three-tier AWS application environment:

```text
Cloudflare DNS
  -> public Application Load Balancer
  -> private web Auto Scaling Group
  -> internal Application Load Balancer
  -> private app Auto Scaling Group
  -> private RDS MySQL
```

## 2. Run Local Quality Checks

Install the documented local tooling, then run:

```bash
pre-commit run --all-files
```

The hooks run Terraform formatting, Terraform validation/tests, generated documentation checks, TFLint, and Checkov.

## 3. Bootstrap Remote State

Create the backend resources once:

```bash
cd environments/backend-bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Use the outputs to create `environments/dev/backend.hcl`.

## 4. Bootstrap GitHub Actions IAM

Create the GitHub OIDC roles used by CI/CD:

```bash
cd ../github-actions-bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
terraform output github_actions_repository_variables
```

Copy the output values into GitHub repository variables. See [ci-cd.md](ci-cd.md) for the full variable and secret list.

## 5. Deploy the Dev Environment

Apply the composed dev environment:

```bash
cd ../dev
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
terraform output github_actions_app_variables
```

Copy the app output values into GitHub repository or environment variables.

## 6. Configure Runtime Parameters

Terraform manages the image tag parameters and the non-secret database config parameter. The RDS password stays in the AWS-managed RDS master user secret.

Create only the manually documented CloudWatch agent SSM parameters before relying on instance bootstrap. Do not manually create the Terraform-managed database config parameter.

Useful outputs:

```bash
terraform -chdir=environments/dev output database_config_parameter_name
terraform -chdir=environments/dev output backend_image_tag_parameter_name
terraform -chdir=environments/dev output frontend_image_tag_parameter_name
```

## 7. Run the Application Deployment Workflow

Trigger the application workflow from GitHub Actions after infrastructure is ready. The workflow builds images, pushes to ECR, runs migrations through SSM, updates image tag parameters, and refreshes the app and web ASGs.

Verify the public endpoint:

```bash
curl https://<public-application-url>/health
curl https://<public-application-url>/app-health
```

## 8. Verify AWS Resources

Recommended checks:

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "<asg-name>" \
  --query "AutoScalingGroups[0].Instances[*].[InstanceId,LifecycleState,HealthStatus]" \
  --output table

aws elbv2 describe-target-health \
  --target-group-arn "<target-group-arn>"

aws logs describe-log-groups \
  --log-group-name-prefix "/dev/deployment-notes"
```

## 9. Destroy the Demo

Destroy the application environment when the review/demo is finished:

```bash
cd environments/dev
terraform destroy
```

Keep `backend-bootstrap` separate unless you intentionally want to remove the remote state bucket and lockfile table.
