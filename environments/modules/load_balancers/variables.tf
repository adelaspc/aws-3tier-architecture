variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "public_alb_sg_id" {
  type = string
}

variable "internal_alb_sg_id" {
  type = string
}

variable "web_target_port" {
  type    = number
  default = 80
}

variable "web_health_check_path" {
  type    = string
  default = "/"
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "app_target_port" {
  type    = number
  default = 5000
}

variable "app_health_check_path" {
  type    = string
  default = "/health"
}

variable "certificate_domain_name" {
  description = "Primary domain name of the existing ACM certificate"
  type        = string
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
