variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "At least two availability zones are required."
  }
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

check "subnet_count_matches_azs" {
  assert {
    condition = alltrue([
      length(var.public_subnets) == length(var.azs),
      length(var.web_subnets) == length(var.azs),
      length(var.app_subnets) == length(var.azs),
      length(var.db_subnets) == length(var.azs),
    ])
    error_message = "Each subnet list must contain exactly one CIDR for every availability zone."
  }
}
