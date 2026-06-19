# Operations

This document covers common operational tasks for the demo environment.

## Demo Lifecycle

The intended lifecycle is:

1. Provision infrastructure.
2. Verify the application and deployment workflow.
3. Destroy the stack to avoid ongoing AWS costs.

This is not intended to run continuously like a production environment.

## Runtime SSM Parameters

The current demo expects some runtime SSM parameters to exist before instances can bootstrap successfully:

- Backend image tag parameter.
- Frontend image tag parameter.
- CloudWatch agent config parameters.
- Database config parameter.

Terraform manages the image tag parameters and the non-secret database config parameter. CloudWatch agent config parameters are created manually for the demo.

Recommended operator flow:

1. Create the CloudWatch agent config parameters before launching instances.
2. Apply Terraform to create RDS, the non-secret database config SSM parameter, and the EC2/ASG infrastructure.
3. Configure GitHub Actions with the Terraform outputs needed by the app deployment workflow.
4. Trigger an ASG Instance Refresh if instances launched before the final runtime parameters were ready.

Useful commands:

```bash
terraform -chdir=environments/dev output rds_endpoint
terraform -chdir=environments/dev output rds_master_user_secret_arn
terraform -chdir=environments/dev output database_config_parameter_name
terraform -chdir=environments/dev output backend_image_tag_parameter_name
terraform -chdir=environments/dev output frontend_image_tag_parameter_name
```

The database config parameter is managed by Terraform and contains only non-secret metadata. Do not create a separate full database URL parameter for the Terraform-managed AWS deployment.

The RDS password remains in the AWS-managed RDS master user secret. The backend EC2 role can read that one secret at runtime and build the SQLAlchemy URL inside the container.

## ECR Repository

The ECR repository is a prerequisite and is not created by the Terraform stack. Create it before the application deployment workflow needs to push images, then set `ecr_repository_name` in Terraform and `ECR_REPOSITORY` in GitHub variables to the same repository name.

## DNS and Certificate Checks

The public ALB requires an existing ACM certificate in the same AWS region as the ALB. The certificate must cover the public hostname produced by `public_record_name` and `public_zone_name`.

When using Cloudflare:

- Keep ACM DNS validation records correct and visible.
- Do not proxy ACM validation records.
- Decide intentionally whether the application CNAME should be proxied.
- If `cloudflare_proxied = true`, test both Cloudflare-facing behavior and direct ALB target health when troubleshooting.

## Health Checks

Useful checks:

```bash
curl https://<public-application-url>/health
curl https://<public-application-url>/app-health
```

From AWS, inspect:

- Public ALB target group health for the web tier.
- Internal ALB target group health for the app tier.
- EC2 system logs and user data logs.
- CloudWatch application and bootstrap log groups.

Useful AWS CLI checks:

```bash
aws elbv2 describe-target-health \
  --target-group-arn "<target-group-arn>"

aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "<asg-name>" \
  --query "AutoScalingGroups[0].Instances[*].[InstanceId,LifecycleState,HealthStatus]" \
  --output table

aws ssm describe-instance-information \
  --filters "Key=InstanceIds,Values=<instance-id>"
```

## Logs

Instance bootstrap writes local user data logs:

- `/var/log/deployment-notes-web-user-data.log`
- `/var/log/deployment-notes-app-user-data.log`

Application containers use the `awslogs` Docker log driver and write to CloudWatch Logs.

Default CloudWatch log group layout:

- `/<environment>/deployment-notes/frontend`
- `/<environment>/deployment-notes/frontend/bootstrap`
- `/<environment>/deployment-notes/backend`
- `/<environment>/deployment-notes/backend/bootstrap`

Useful commands:

```bash
aws logs describe-log-groups \
  --log-group-name-prefix "/dev/deployment-notes"

aws logs tail "/dev/deployment-notes/backend" \
  --since 30m \
  --follow
```

From an instance through Session Manager:

```bash
docker ps
docker logs <container-name> --tail 100
sudo tail -n 100 /var/log/deployment-notes-app-user-data.log
sudo tail -n 100 /var/log/deployment-notes-web-user-data.log
```

## Enable ALB Access Logs

ALB access logs are disabled by default to reduce demo cost. Enable them per environment when request-level traffic auditing, debugging, or basic traffic analysis is needed.

Example using a Terraform-managed bucket with a generated unique name:

```hcl
alb_access_logs = {
  enabled        = true
  object_prefix  = "dev"
  retention_days = 7
}
```

Example using an explicit bucket name:

```hcl
alb_access_logs = {
  enabled        = true
  bucket_name    = "example-dev-alb-access-logs"
  object_prefix  = "dev"
  retention_days = 7
}
```

When enabled, logs are written under separate prefixes for the public and internal ALBs.
If Terraform creates the bucket with a generated name, use the `alb_access_logs_bucket_name` output to find it.

## ASG Instance Refresh

Application releases trigger Instance Refresh from GitHub Actions.

For manual refresh after an infrastructure change:

```bash
./scripts/wait-asg-refresh.sh <asg-name>
```

The helper starts a refresh and waits until it succeeds or fails. It accepts these optional environment variables:

- `POLL_SECONDS`, default `15`.
- `MAX_ATTEMPTS`, default `80`.
- `INSTANCE_WARMUP`, default `120`.
- `MIN_HEALTHY_PERCENTAGE`, default `100`.

Example:

```bash
INSTANCE_WARMUP=180 MIN_HEALTHY_PERCENTAGE=50 ./scripts/wait-asg-refresh.sh <asg-name>
```

Run Instance Refresh after Terraform changes that affect EC2 runtime configuration, including AMI, user data, IAM instance profile, security group behavior, or instance type. Terraform creates a new Launch Template version, but existing instances are not automatically replaced just because the Launch Template changed.

To inspect refresh status manually:

```bash
aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name "<asg-name>" \
  --output table
```

## Application Deployment

The app deployment workflow is the normal release path for application changes. It:

1. Runs backend and frontend tests.
2. Builds backend and frontend images.
3. Pushes the images to the prerequisite ECR repository.
4. Runs database migrations through SSM on one healthy app instance.
5. Updates backend and frontend image tag parameters in SSM.
6. Starts Instance Refresh for the app ASG.
7. Starts Instance Refresh for the web ASG.

Required GitHub variables for deployment are documented in [ci-cd.md](ci-cd.md). The most important runtime names can be copied from Terraform outputs after apply:

```bash
terraform -chdir=environments/dev output backend_image_tag_parameter_name
terraform -chdir=environments/dev output frontend_image_tag_parameter_name
```

For a manual image tag rotation, update the SSM image tag parameters and refresh the affected ASGs:

```bash
aws ssm put-parameter \
  --name "<backend-image-tag-parameter-name>" \
  --type String \
  --value "backend-<tag>" \
  --overwrite

aws ssm put-parameter \
  --name "<frontend-image-tag-parameter-name>" \
  --type String \
  --value "frontend-<tag>" \
  --overwrite

./scripts/wait-asg-refresh.sh <app-asg-name>
./scripts/wait-asg-refresh.sh <web-asg-name>
```

## Scaling

Adjust desired capacity through Terraform variables:

- `web_desired_capacity`
- `app_desired_capacity`

For persistent changes, prefer Terraform over manual console edits.

For temporary testing, you can inspect capacity from AWS:

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "<asg-name>" \
  --query "AutoScalingGroups[0].[MinSize,DesiredCapacity,MaxSize]" \
  --output table
```

## Maintenance

Common maintenance tasks:

- Rotate image tags by publishing new backend/frontend images, updating the SSM image tag parameters, and running ASG Instance Refresh.
- Update the AMI by baking or selecting a new custom AMI, changing `custom_ami_id`, applying Terraform, and refreshing the web and app ASGs.
- Update application dependencies in `deployment-notes/`, run tests, build new images, and deploy through the application workflow.
- Update Terraform provider versions intentionally, review the lockfile changes, then run formatting, validation, linting, and a Terraform plan.
- Regenerate Terraform references after changing variables, outputs, providers, or resources:

  ```bash
  for module_dir in environments/modules/*; do
    [ -d "$module_dir" ] || continue
    terraform-docs --config .terraform-docs.yml "$module_dir"
  done

  terraform-docs --config .terraform-docs.yml environments/dev
  ```

- Review CloudWatch log retention and clean up old demo resources after test runs.

For infrastructure changes that affect running EC2 instances, assume an ASG Instance Refresh is required after `terraform apply`.

## Destroy

Destroy the application environment when done:

```bash
cd environments/dev
terraform destroy
```

The remote state bucket and GitHub Actions IAM bootstrap are separate and should not be destroyed unless you are retiring the repository setup.
