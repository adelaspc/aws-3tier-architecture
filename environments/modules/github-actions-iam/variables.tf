variable "project" {
  description = "Project name used for IAM role and policy names."
  type        = string
}

variable "environment" {
  description = "Environment name used for IAM role and policy names."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/name format"
  type        = string

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "github_repository must use the owner/name format."
  }
}

variable "github_environment" {
  description = "GitHub Environment name allowed to assume the Terraform apply role."
  type        = string
  default     = "terraform-dev"
}

variable "github_app_environment" {
  description = "GitHub Environment name allowed to assume the application deployment role."
  type        = string
  default     = "app-dev"
}

variable "ecr_repository_name" {
  description = "ECR repository name that the application deployment role can push to."
  type        = string
  default     = "deployments-notes-app"
}

variable "state_bucket_name" {
  description = "S3 bucket name containing Terraform remote state."
  type        = string
}

variable "dev_state_key" {
  description = "S3 object key for the dev Terraform state file."
  type        = string
}

variable "deployment_app_ssm_prefix" {
  description = "SSM Parameter Store prefix used by application deployment image tag parameters."
  type        = string
  default     = null
}
