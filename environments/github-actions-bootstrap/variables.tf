variable "project" {
  description = "Project name passed to the GitHub Actions IAM module."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.project))
    error_message = "project must be 3-32 characters, start with a lowercase letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name passed to the GitHub Actions IAM module."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.environment))
    error_message = "environment must be 3-22 characters, start with a lowercase letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "AWS region used by the bootstrap provider."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "region must look like an AWS region, for example us-east-1."
  }
}

variable "github_repository" {
  description = "GitHub repository in owner/name format allowed by OIDC trust policies."
  type        = string
  default     = "adelaspc/aws-3tier-architecture"

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
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

  validation {
    condition     = can(regex("^[a-z0-9]+(?:[._/-][a-z0-9]+)*$", var.ecr_repository_name))
    error_message = "ecr_repository_name must be a valid ECR repository name."
  }
}

variable "state_bucket_name" {
  description = "S3 bucket name containing Terraform remote state."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name)) && !can(regex("\\.\\.", var.state_bucket_name))
    error_message = "state_bucket_name must be a valid S3 bucket name."
  }
}

variable "dev_state_key" {
  description = "S3 object key for the dev Terraform state file."
  type        = string
  default     = "aws-3tier-architecture/dev/terraform.tfstate"

  validation {
    condition     = length(trimspace(var.dev_state_key)) > 0 && !startswith(var.dev_state_key, "/")
    error_message = "dev_state_key must be a non-empty relative S3 object key."
  }
}

variable "deployment_app_ssm_prefix" {
  description = "SSM Parameter Store prefix used by application deployment image tag parameters."
  type        = string
  default     = null

  validation {
    condition     = var.deployment_app_ssm_prefix == null || startswith(var.deployment_app_ssm_prefix, "/")
    error_message = "deployment_app_ssm_prefix must start with / when provided."
  }
}
