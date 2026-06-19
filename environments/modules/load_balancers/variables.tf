variable "project" {
  description = "Project name used for resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name used for resource names and tags."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where load balancers and target groups are created."
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnet IDs for the internet-facing public ALB."
  type        = list(string)
}

variable "public_alb_sg_id" {
  description = "Security group ID attached to the public ALB."
  type        = string
}

variable "internal_alb_sg_id" {
  description = "Security group ID attached to the internal ALB."
  type        = string
}

variable "web_target_port" {
  description = "Port used by the public ALB target group for web instances."
  type        = number
  default     = 80

  validation {
    condition     = var.web_target_port >= 1 && var.web_target_port <= 65535
    error_message = "web_target_port must be between 1 and 65535."
  }
}

variable "web_health_check_path" {
  description = "HTTP health check path for the web target group."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.web_health_check_path, "/")
    error_message = "web_health_check_path must start with /."
  }
}

variable "app_subnet_ids" {
  description = "Subnet IDs for the internal ALB."
  type        = list(string)
}

variable "app_target_port" {
  description = "Port used by the internal ALB target group for app instances."
  type        = number
  default     = 5000

  validation {
    condition     = var.app_target_port >= 1 && var.app_target_port <= 65535
    error_message = "app_target_port must be between 1 and 65535."
  }
}

variable "app_health_check_path" {
  description = "HTTP health check path for the app target group."
  type        = string
  default     = "/health"

  validation {
    condition     = startswith(var.app_health_check_path, "/")
    error_message = "app_health_check_path must start with /."
  }
}

variable "certificate_domain_name" {
  description = "Primary domain name of the existing ACM certificate"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.certificate_domain_name))
    error_message = "certificate_domain_name must be a valid DNS name."
  }
}

variable "acm_certificate_arn" {
  description = "Optional explicit ARN of the existing ACM certificate"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.acm_certificate_arn == null || can(regex("^arn:[^:]+:acm:[^:]+:[0-9]+:certificate/.+$", var.acm_certificate_arn))
    error_message = "acm_certificate_arn must be a valid ACM certificate ARN."
  }
}

variable "alb_access_logs" {
  description = "ALB access log configuration. Disabled by default to reduce demo environment costs."
  type = object({
    enabled        = bool
    bucket_name    = optional(string)
    bucket_prefix  = optional(string, "alb-access-logs")
    object_prefix  = optional(string, "alb")
    retention_days = optional(number, 7)
  })

  default = {
    enabled = false
  }

  validation {
    condition     = var.alb_access_logs.retention_days >= 1
    error_message = "alb_access_logs.retention_days must be at least 1."
  }

  validation {
    condition     = length(trim(var.alb_access_logs.object_prefix, "/")) > 0
    error_message = "alb_access_logs.object_prefix must not be empty."
  }
}
