variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "web_subnet_ids" {
  type = list(string)
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "web_security_group_id" {
  type = string
}

variable "app_security_group_id" {
  type = string
}

variable "web_target_group_arn" {
  type = string
}

variable "app_target_group_arn" {
  type = string
}

variable "internal_alb_dns_name" {
  type = string
}

variable "custom_ami_id" {
  description = "ID of the custom baked AMI used by web and app instances"
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.custom_ami_id))
    error_message = "custom_ami_id must be a valid AMI ID."
  }
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

variable "cloudwatch_log_retention_days" {
  type    = number
  default = 7
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

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "web_desired_capacity" {
  type    = number
  default = 2
}

variable "app_desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "app_port" {
  type    = number
  default = 5000
}
