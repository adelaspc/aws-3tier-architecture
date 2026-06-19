data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "alb_logs" {
  count = var.alb_access_logs.enabled ? 1 : 0

  statement {
    sid     = "AWSLogDeliveryWrite"
    effect  = "Allow"
    actions = ["s3:PutObject"]

    resources = [
      for tier in ["public", "internal"] :
      "${aws_s3_bucket.alb_logs[0].arn}/${local.alb_access_logs_object_prefix}/${tier}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket" "alb_logs" {
  #checkov:skip=CKV_AWS_18: Server access logging is omitted to avoid recursive logging and extra demo cost
  #checkov:skip=CKV_AWS_21: Versioning is omitted for disposable ALB logs with lifecycle expiration
  #checkov:skip=CKV_AWS_144: Cross-region replication is omitted for short-lived demo logs
  #checkov:skip=CKV_AWS_145: SSE-S3 encryption is sufficient for optional short-lived demo ALB logs
  #checkov:skip=CKV2_AWS_62: Event notifications are not required for demo ALB access logs
  count = var.alb_access_logs.enabled ? 1 : 0

  bucket        = var.alb_access_logs.bucket_name
  bucket_prefix = var.alb_access_logs.bucket_name == null ? "${local.name_prefix}-${var.alb_access_logs.bucket_prefix}-" : null

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-alb-access-logs"
    Purpose = "alb-access-logs"
  })
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  count = var.alb_access_logs.enabled ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  count = var.alb_access_logs.enabled ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  count = var.alb_access_logs.enabled ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  count = var.alb_access_logs.enabled ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    id     = "expire-alb-access-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.alb_access_logs.retention_days
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  count = var.alb_access_logs.enabled ? 1 : 0

  bucket = aws_s3_bucket.alb_logs[0].id
  policy = data.aws_iam_policy_document.alb_logs[0].json
}
