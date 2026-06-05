variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "web_subnets" {
  type = list(string)
}

variable "app_subnets" {
  type = list(string)
}

variable "db_subnets" {
  type = list(string)
}

variable "public_zone_name" {
  type = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the public DNS zone"
  type        = string
}

variable "public_record_name" {
  description = "Cloudflare DNS record name for the public application"
  type        = string
  default     = "www"
}

variable "cloudflare_proxied" {
  description = "Whether Cloudflare should proxy traffic for the public application record"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "Optional ARN of an existing ACM certificate covering the public domain"
  type        = string
  nullable    = true
}

variable "private_zone_name" {
  type    = string
  default = "deployment-notes.internal"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "custom_ami_id" {
  description = "ID of the custom baked AMI used by web and app instances"
  type        = string
}

variable "ecr_repository_name" {
  description = "Existing ECR repository containing frontend and backend images"
  type        = string
  default     = "deployments-notes-app"
}

variable "initial_backend_image_tag" {
  description = "Initial backend image tag stored in SSM; application pipeline updates it later"
  type        = string
  default     = "backend-2.0.0"
}

variable "initial_frontend_image_tag" {
  description = "Initial frontend image tag stored in SSM; application pipeline updates it later"
  type        = string
  default     = "frontend-2.0.1"
}

variable "deployment_app_ssm_prefix" {
  description = "SSM Parameter Store prefix used by the deployment-notes app"
  type        = string
  default     = null
}

variable "cloudwatch_log_group_prefix" {
  description = "CloudWatch Logs prefix for application and bootstrap logs"
  type        = string
  default     = null
}

variable "backend_container_name" {
  type    = string
  default = "deployment-notes-backend"
}

variable "frontend_container_name" {
  type    = string
  default = "deployment-notes-frontend"
}

variable "backend_log_level" {
  type    = string
  default = "INFO"
}

variable "backend_gunicorn_workers" {
  type    = number
  default = 2
}

variable "backend_gunicorn_threads" {
  type    = number
  default = 4
}

variable "container_health_check_attempts" {
  type    = number
  default = 10
}

variable "container_health_check_interval_seconds" {
  type    = number
  default = 3
}

variable "web_desired_capacity" {
  type    = number
  default = 2
}

variable "app_desired_capacity" {
  type    = number
  default = 2
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "database_name" {
  type    = string
  default = "deployment_notes"
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}
