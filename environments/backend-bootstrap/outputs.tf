output "state_bucket_name" {
  description = "Name of the Terraform remote state S3 bucket."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "backend_config" {
  description = "Backend configuration values for environments using this state bucket."
  value = {
    bucket       = aws_s3_bucket.terraform_state.bucket
    region       = var.region
    use_lockfile = true
  }
}
