locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  public_subnet_map = {
    for i, cidr in var.public_subnets : i => {
      cidr = cidr
      az   = var.azs[i]
      name = "${local.name_prefix}-subnet-public-${substr(var.azs[i], -1, 1)}"
    }
  }

  web_subnet_map = {
    for i, cidr in var.web_subnets : i => {
      cidr = cidr
      az   = var.azs[i]
      name = "${local.name_prefix}-subnet-web-${substr(var.azs[i], -1, 1)}"
    }
  }

  app_subnet_map = {
    for i, cidr in var.app_subnets : i => {
      cidr = cidr
      az   = var.azs[i]
      name = "${local.name_prefix}-subnet-app-${substr(var.azs[i], -1, 1)}"
    }
  }

  db_subnet_map = {
    for i, cidr in var.db_subnets : i => {
      cidr = cidr
      az   = var.azs[i]
      name = "${local.name_prefix}-subnet-db-${substr(var.azs[i], -1, 1)}"
    }
  }
}

