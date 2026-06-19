variable "project" {
  description = "Project name used for resource names and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.project))
    error_message = "project must be 3-32 characters, start with a lowercase letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name used for resource names and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.environment))
    error_message = "environment must be 3-22 characters, start with a lowercase letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block."
  }

  validation {
    condition = can(alltrue([
      for cidr in flatten([var.public_subnets, var.web_subnets, var.app_subnets, var.db_subnets]) :
      cidrcontains(var.vpc_cidr, cidrhost(cidr, 0)) && cidrcontains(var.vpc_cidr, cidrhost(cidr, -1))
      ])) ? alltrue([
      for cidr in flatten([var.public_subnets, var.web_subnets, var.app_subnets, var.db_subnets]) :
      cidrcontains(var.vpc_cidr, cidrhost(cidr, 0)) && cidrcontains(var.vpc_cidr, cidrhost(cidr, -1))
    ]) : true
    error_message = "All subnet CIDR blocks must be contained within vpc_cidr."
  }

  validation {
    condition = can(cidrnetmask(var.vpc_cidr)) ? (can(alltrue(flatten([
      for i, cidr_a in flatten([var.public_subnets, var.web_subnets, var.app_subnets, var.db_subnets]) : [
        for j, cidr_b in flatten([var.public_subnets, var.web_subnets, var.app_subnets, var.db_subnets]) :
        i == j || !(cidrcontains(cidr_a, cidrhost(cidr_b, 0)) || cidrcontains(cidr_b, cidrhost(cidr_a, 0)))
      ]
      ]))) ? alltrue(flatten([
      for i, cidr_a in flatten([var.public_subnets, var.web_subnets, var.app_subnets, var.db_subnets]) : [
        for j, cidr_b in flatten([var.public_subnets, var.web_subnets, var.app_subnets, var.db_subnets]) :
        i == j || !(cidrcontains(cidr_a, cidrhost(cidr_b, 0)) || cidrcontains(cidr_b, cidrhost(cidr_a, 0)))
      ]
    ])) : true) : true
    error_message = "Subnet CIDR blocks must not overlap."
  }
}

variable "azs" {
  description = "Availability Zones used by the subnet layout."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "At least two availability zones are required."
  }
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets, one per Availability Zone."
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.public_subnets : can(cidrnetmask(cidr))])
    error_message = "public_subnets must contain valid CIDR blocks."
  }
}

variable "web_subnets" {
  description = "CIDR blocks for private web-tier subnets, one per Availability Zone."
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.web_subnets : can(cidrnetmask(cidr))])
    error_message = "web_subnets must contain valid CIDR blocks."
  }
}

variable "app_subnets" {
  description = "CIDR blocks for private app-tier subnets, one per Availability Zone."
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.app_subnets : can(cidrnetmask(cidr))])
    error_message = "app_subnets must contain valid CIDR blocks."
  }
}

variable "db_subnets" {
  description = "CIDR blocks for isolated database subnets, one per Availability Zone."
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.db_subnets : can(cidrnetmask(cidr))])
    error_message = "db_subnets must contain valid CIDR blocks."
  }
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
