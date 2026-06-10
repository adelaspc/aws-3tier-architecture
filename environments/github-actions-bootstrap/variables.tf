variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "github_repository" {
  type    = string
  default = "adelaspc/aws-3tier-architecture"
}

variable "github_environment" {
  type    = string
  default = "terraform-dev"
}

variable "state_bucket_name" {
  type = string
}

variable "dev_state_key" {
  type    = string
  default = "aws-3tier-architecture/dev/terraform.tfstate"
}

variable "deployment_app_ssm_prefix" {
  type    = string
  default = null
}
