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
  #checkov:skip=CKV2_AWS_60: Final snapshots are intentionally omitted for disposable demo data
  identifier = "${local.name_prefix}-mysql"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name                     = var.database_name
  username                    = var.master_username
  manage_master_user_password = true

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.security_group_id]
  multi_az               = var.multi_az
  publicly_accessible    = false

  backup_retention_period = 7
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-mysql"
  })
}
