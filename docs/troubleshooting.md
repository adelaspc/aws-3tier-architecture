# Troubleshooting

Use this document as a first-pass diagnostic checklist. Prefer checking the path in order: DNS, public ALB, web tier, internal ALB, app tier, RDS, then deployment automation.

## Web Tier Cannot Reach Internal ALB

Check:

- Web EC2 security group egress to the internal ALB security group.
- Internal ALB security group ingress from the web EC2 security group.
- Private Route 53 record for the internal API name.
- Internal ALB target group health.
- Nginx container environment variable `APP_INTERNAL_ALB_DNS`.

Useful commands from a web instance:

```bash
curl -v http://<internal-alb-dns>/health
curl -v http://localhost/app-health
docker exec <frontend-container-name> printenv APP_INTERNAL_ALB_DNS
docker logs <frontend-container-name> --tail 100
```

Useful AWS checks:

```bash
aws elbv2 describe-target-health \
  --target-group-arn "<internal-app-target-group-arn>"

aws route53 list-resource-record-sets \
  --hosted-zone-id "<private-hosted-zone-id>"
```

Likely causes:

- The internal ALB target group has no healthy app instances.
- The private DNS record points to the wrong ALB.
- The web instance has stale user data and needs Instance Refresh.
- Security group rules do not allow web-to-internal-ALB traffic.

## App Tier Cannot Reach RDS

Check:

- App EC2 security group egress to the DB security group.
- DB security group ingress from the app EC2 security group.
- RDS endpoint and port.
- Database config SSM parameter value.
- Whether the backend container can call SSM and read the RDS managed secret.

Useful commands from an app instance:

```bash
aws ssm get-parameter \
  --name "<database-config-parameter-name>" \
  --query "Parameter.Value" \
  --output text

aws secretsmanager get-secret-value \
  --secret-id "<rds-master-user-secret-arn>" \
  --query "Name" \
  --output text

docker logs <backend-container-name> --tail 100
curl -v http://localhost:5000/health
curl -v http://localhost:5000/health/db
```

Useful AWS checks:

```bash
aws rds describe-db-instances \
  --db-instance-identifier "<db-instance-id>" \
  --query "DBInstances[0].[DBInstanceStatus,Endpoint.Address,Endpoint.Port,PubliclyAccessible]" \
  --output table
```

Likely causes:

- The Terraform-managed database config parameter has stale endpoint metadata.
- The app instance role cannot read the database config parameter or RDS managed secret.
- RDS is still creating, modifying, or rebooting.
- Security groups do not allow app-to-database traffic on port `3306`.

## Instances Are Unhealthy In Target Groups

Check:

- User data logs on the instance.
- Container status with `docker ps`.
- Container logs with `docker logs <container-name>`.
- ALB health check path and port.
- Security group rules between ALB and instance tier.

Useful commands:

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "<asg-name>" \
  --query "AutoScalingGroups[0].Instances[*].[InstanceId,LifecycleState,HealthStatus]" \
  --output table

aws elbv2 describe-target-health \
  --target-group-arn "<target-group-arn>" \
  --query "TargetHealthDescriptions[*].[Target.Id,TargetHealth.State,TargetHealth.Reason,TargetHealth.Description]" \
  --output table
```

Useful commands from an instance:

```bash
docker ps
docker logs <container-name> --tail 100
sudo tail -n 100 /var/log/cloud-init-output.log
sudo tail -n 100 /var/log/deployment-notes-app-user-data.log
sudo tail -n 100 /var/log/deployment-notes-web-user-data.log
```

Likely causes:

- The Docker image tag in SSM does not exist in ECR.
- The instance cannot reach ECR, SSM, or CloudWatch through NAT.
- Required runtime SSM parameters are missing.
- The container starts but fails its local health check.

## GitHub OIDC Assume Role Fails

Check:

- GitHub Environment name matches the IAM trust policy subject.
- Workflow job uses the correct environment.
- Repository name matches the `owner/name` value used during IAM bootstrap.
- The job has `id-token: write` permission.
- The role ARN is configured as a GitHub variable, not a secret, where the workflow expects `vars.*`.
- The AWS account has the GitHub OIDC provider for `token.actions.githubusercontent.com`.

Useful checks:

```bash
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn "<github-oidc-provider-arn>"

aws iam get-role \
  --role-name "<role-name>"
```

Likely causes:

- The GitHub Environment name in the workflow does not match the IAM trust policy subject.
- The role was bootstrapped for a different repository name.
- The workflow is running from a fork or untrusted context where the role should not be assumable.

## Application Deployment Cannot Run Migration

Check:

- `APP_ASG_NAME` GitHub variable.
- At least one healthy InService app instance exists.
- The selected instance is SSM Online.
- App deploy role can call `ssm:SendCommand`.
- Database config parameter exists and is readable by the app instance role.
- RDS managed secret is readable by the app instance role.
- The backend image was pushed to ECR before the migration step runs.
- The app deploy role can only send commands to app-tier instances tagged with the expected project/environment/tier tags.

Useful commands:

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "<app-asg-name>" \
  --query "AutoScalingGroups[0].Instances[?LifecycleState=='InService' && HealthStatus=='Healthy'].InstanceId" \
  --output text

aws ssm describe-instance-information \
  --filters "Key=PingStatus,Values=Online"

aws ssm get-command-invocation \
  --command-id "<command-id>" \
  --instance-id "<instance-id>" \
  --query "{Status:Status,Stdout:StandardOutputContent,Stderr:StandardErrorContent}" \
  --output json
```

Likely causes:

- No healthy app instance exists yet.
- The app instance is healthy in EC2 but not registered as SSM Online.
- IAM scoping blocks `ssm:SendCommand` because the target is not tagged as the app tier.
- The migration container cannot read the database config parameter or RDS managed secret.

## Public URL Does Not Load

Check:

- Cloudflare DNS record points to the public ALB DNS name.
- ACM certificate covers the public hostname.
- ACM certificate is issued in the same AWS region as the public ALB.
- Public ALB listener and target group are healthy.
- Web ASG has healthy instances.
- Cloudflare proxy mode is configured as intended.
- ACM DNS validation records are not proxied in Cloudflare.

Useful commands:

```bash
terraform -chdir=environments/dev output public_application_url

dig <public-hostname>

curl -v https://<public-hostname>/health
curl -v https://<public-hostname>/app-health

aws elbv2 describe-load-balancers \
  --names "<public-alb-name>"
```

Likely causes:

- DNS is still propagating or Cloudflare is proxying differently than expected.
- The ACM certificate does not include the final public hostname.
- The web target group is unhealthy.
- The web container cannot reach the internal app ALB, so `/health` works but `/app-health` fails.

## Terraform Apply Succeeds But Instances Still Run Old Configuration

Check:

- Whether Terraform created a new Launch Template version.
- Whether the ASG references `$Latest`.
- Whether an Instance Refresh was started after `terraform apply`.

Useful commands:

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "<asg-name>" \
  --query "AutoScalingGroups[0].LaunchTemplate"

aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name "<asg-name>" \
  --output table
```

Likely cause:

- This is expected ASG behavior. Existing EC2 instances are not automatically replaced just because Terraform created a new Launch Template version. Start an Instance Refresh after infrastructure changes that affect runtime configuration.

## ALB Access Logs Are Empty

Check:

- `alb_access_logs.enabled` is `true`.
- The bucket exists and has the generated ALB log delivery policy.
- Traffic has reached the ALB since access logs were enabled.
- Enough time has passed for ALB log delivery.

Useful commands:

```bash
terraform -chdir=environments/dev output alb_access_logs_bucket_name

aws s3 ls "s3://<alb-access-logs-bucket>/<prefix>/" --recursive
```

Likely causes:

- Access logs are disabled by default for demo cost control.
- The wrong bucket or prefix is being checked.
- No requests have reached the ALB yet.
