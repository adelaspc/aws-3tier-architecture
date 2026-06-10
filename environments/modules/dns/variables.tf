variable "vpc_id" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "public_record_name" {
  type = string
}

variable "public_alb_dns_name" {
  type = string
}

variable "cloudflare_proxied" {
  type    = bool
  default = false
}

variable "private_zone_name" {
  type    = string
  default = "deployment-notes.internal"
}

variable "private_record_name" {
  type    = string
  default = "api"
}

variable "internal_alb_dns_name" {
  type = string
}

variable "internal_alb_zone_id" {
  type = string
}
