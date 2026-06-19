variable "vpc_id" {
  description = "VPC ID associated with the private hosted zone."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID where the public application record is managed."
  type        = string
}

variable "public_zone_name" {
  description = "Public DNS zone name used to build the application FQDN."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.public_zone_name))
    error_message = "public_zone_name must be a valid DNS zone name."
  }
}

variable "public_record_name" {
  description = "Cloudflare DNS record name for the public application."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]+$", var.public_record_name))
    error_message = "public_record_name must contain only DNS-safe characters."
  }
}

variable "public_alb_dns_name" {
  description = "DNS name of the public ALB used as the Cloudflare CNAME target."
  type        = string
}

variable "cloudflare_proxied" {
  description = "Whether Cloudflare should proxy the public application record."
  type        = bool
  default     = false
}

variable "private_zone_name" {
  description = "Private Route 53 hosted zone name."
  type        = string
  default     = "deployment-notes.internal"

  validation {
    condition     = can(regex("^[A-Za-z0-9.-]+$", var.private_zone_name))
    error_message = "private_zone_name must be a valid private DNS zone name."
  }
}

variable "private_record_name" {
  description = "Private DNS record name pointing to the internal ALB."
  type        = string
  default     = "api"

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]+$", var.private_record_name))
    error_message = "private_record_name must contain only DNS-safe characters."
  }
}

variable "internal_alb_dns_name" {
  description = "DNS name of the internal ALB."
  type        = string
}

variable "internal_alb_zone_id" {
  description = "Route 53 zone ID of the internal ALB for alias records."
  type        = string
}
