# Recovery

This environment is optimized for demo teardown, not production recovery. Recovery guidance focuses on restoring a working demo quickly.

## Failed Application Release

If a new image fails health checks:

1. Confirm which image tag was written to SSM.
2. Restore the previous backend or frontend image tag parameter.
3. Start ASG Instance Refresh for the affected tier.
4. Confirm target group health.

## Failed Database Migration

If migration through SSM fails:

1. Inspect the SSM command invocation output.
2. Check that the selected app instance is SSM Online.
3. Confirm the backend image can read the database config parameter and RDS managed secret.
4. Re-run the application workflow after correcting the issue.

## Unhealthy ASG After Terraform Apply

If Terraform changed AMI, user data, IAM profile, or instance type:

1. Start Instance Refresh.
2. Check EC2 user data logs.
3. Check ALB target health reason codes.
4. Verify required SSM parameters exist.

## RDS Data Recovery

The demo defaults favor easy teardown:

- Deletion protection is disabled by default.
- Final snapshots are skipped by default.

For production-like recovery, set `db_deletion_protection = true`, `db_skip_final_snapshot = false`, choose a `db_final_snapshot_identifier`, increase `db_backup_retention_period` if needed, and test restore procedures.
