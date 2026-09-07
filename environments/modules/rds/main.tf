locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_db_instance" "main" {
  #checkov:skip=CKV_AWS_118: Enhanced monitoring cost is intentionally omitted for the short-lived demo
  #checkov:skip=CKV_AWS_129: Database log exports are intentionally omitted for the short-lived demo
  #checkov:skip=CKV_AWS_161: The demo application uses password authentication from SSM, not IAM DB authentication
  #checkov:skip=CKV_AWS_226: Automatic minor upgrades are avoided during short-lived, manually scheduled demos
  #checkov:skip=CKV_AWS_293: Deletion protection is configurable and disabled to support terraform destroy
  #checkov:skip=CKV_AWS_353: Performance Insights is omitted for the short-lived demo; production should enable an observability profile intentionally
  #checkov:skip=CKV2_AWS_60: Final snapshots are intentionally omitted for disposable demo data
  identifier = "${local.name_prefix}-mysql"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  db_name                     = var.database_name
  username                    = var.master_username
  manage_master_user_password = true

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.security_group_id]
  multi_az               = var.multi_az
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : coalesce(
    var.final_snapshot_identifier,
    "${local.name_prefix}-mysql-final-snapshot",
  )
  apply_immediately = var.apply_immediately

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-mysql"
  })
}
