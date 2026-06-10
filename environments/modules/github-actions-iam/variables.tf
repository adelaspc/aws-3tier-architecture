variable "project" {
  type = string
}

variable "environment" {
  type = string
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
  type    = string
  default = "terraform-dev"
}

variable "state_bucket_name" {
  type = string
}

variable "dev_state_key" {
  type = string
}

variable "deployment_app_ssm_prefix" {
  type    = string
  default = null
}
