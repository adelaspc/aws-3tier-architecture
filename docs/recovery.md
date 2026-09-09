# Recovery

This environment is optimized for demo teardown, not production recovery. Recovery guidance focuses on restoring a working demo quickly.

## Failed Application Release

Application release rollback is manual in the current demo. The workflow does
not automatically save or restore the previous SSM image tags.

If a new image fails health checks or an Instance Refresh fails:

1. Identify the last known-good backend and frontend image tags in ECR or the deployment history.
2. Restore both SSM image tag parameters so the release remains internally consistent.
3. If an Instance Refresh is still active, cancel it and wait for cancellation to complete.
4. Start a new Instance Refresh for each tier that may have launched instances from the failed release.
5. Confirm both target groups are healthy and all instances use the expected images.

Automatic restoration of image tags and coordinated ASG rollback are documented future improvements. They are intentionally not claimed as current workflow behavior because the demo implementation has not been validated against a live rollback scenario.

## Failed Database Migration

If migration through SSM fails:

1. Inspect the SSM command invocation output.
2. Check that the selected app instance is SSM Online.
3. Confirm the backend image can read the database config parameter and RDS managed secret.
4. Re-run the application workflow after correcting the issue.

The migration runs before the workflow publishes new image tags. A successful
migration is not reversed automatically if a later Instance Refresh fails.
Schema changes must therefore remain compatible with both the currently running
backend and the new backend during the rolling deployment. For destructive
changes, use an expand/deploy/contract sequence rather than removing or renaming
schema elements in the same release.

## Unhealthy ASG After Terraform Apply

If Terraform changed AMI, user data, IAM profile, or instance type:

1. Start Instance Refresh.
2. Check EC2 user data logs.
3. Check ALB target health reason codes.
4. Verify required SSM parameters exist.

The ASGs currently use the AWS default health-check grace period. Making
`health_check_grace_period` configurable and sizing it for user-data execution,
image pulls, and container startup is a future improvement rather than tested
behavior in this demo.

## RDS Data Recovery

The demo defaults favor easy teardown:

- Deletion protection is disabled by default.
- Final snapshots are skipped by default.

For production-like recovery, set `db_deletion_protection = true`, `db_skip_final_snapshot = false`, choose a `db_final_snapshot_identifier`, increase `db_backup_retention_period` if needed, and test restore procedures.
