output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "backend_config" {
  value = {
    bucket       = aws_s3_bucket.terraform_state.bucket
    region       = var.region
    use_lockfile = true
  }
}
