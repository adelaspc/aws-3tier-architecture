locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Purpose     = "terraform-state"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  #checkov:skip=CKV_AWS_18: Short-lived portfolio environment; dedicated access logging bucket is intentionally omitted
  #checkov:skip=CKV_AWS_144: Single-region demo state; cross-region replication cost is intentionally omitted
  #checkov:skip=CKV_AWS_145: AWS-managed AES256 encryption is sufficient for this demo state
  #checkov:skip=CKV2_AWS_61: State history is protected by versioning; lifecycle expiration is intentionally manual
  #checkov:skip=CKV2_AWS_62: Terraform state changes do not require event notifications in this demo
  bucket = var.state_bucket_name

  tags = merge(local.common_tags, {
    Name = var.state_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
