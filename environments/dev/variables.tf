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

variable "region" {
  description = "AWS region where the dev stack is deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "region must look like an AWS region, for example us-east-1."
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
    condition     = length(var.azs) >= 2 && length(distinct(var.azs)) == length(var.azs)
    error_message = "azs must contain at least two unique Availability Zones."
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

variable "public_zone_name" {
  description = "Public DNS zone name used for the application hostname and ACM lookup."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.public_zone_name))
    error_message = "public_zone_name must be a valid DNS zone name."
  }
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the public DNS zone"
  type        = string

  validation {
    condition     = length(trimspace(var.cloudflare_zone_id)) > 0
    error_message = "cloudflare_zone_id must not be empty."
  }
}

variable "public_record_name" {
  description = "Cloudflare DNS record name for the public application"
  type        = string
  default     = "www"

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]+$", var.public_record_name))
    error_message = "public_record_name must contain only DNS-safe characters."
  }
}

variable "cloudflare_proxied" {
  description = "Whether Cloudflare should proxy traffic for the public application record"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "Optional ARN of an existing ACM certificate covering the public domain"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.acm_certificate_arn == null || can(regex("^arn:[^:]+:acm:[^:]+:[0-9]+:certificate/.+$", var.acm_certificate_arn))
    error_message = "acm_certificate_arn must be a valid ACM certificate ARN when provided."
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

variable "private_zone_name" {
  description = "Private Route 53 hosted zone name for internal API routing."
  type        = string
  default     = "deployment-notes.internal"

  validation {
    condition     = can(regex("^[A-Za-z0-9.-]+$", var.private_zone_name))
    error_message = "private_zone_name must be a valid private DNS zone name."
  }
}

variable "instance_type" {
  description = "EC2 instance type for web and app instances."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9a-z]*\\.[a-z0-9]+$", var.instance_type))
    error_message = "instance_type must look like an EC2 instance type, for example t3.micro."
  }
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

  validation {
    condition     = can(regex("^[a-z0-9]+(?:[._/-][a-z0-9]+)*$", var.ecr_repository_name))
    error_message = "ecr_repository_name must be a valid ECR repository name."
  }
}

variable "initial_backend_image_tag" {
  description = "Initial backend image tag stored in SSM; application pipeline updates it later"
  type        = string
  default     = "backend-2.0.0"

  validation {
    condition     = length(trimspace(var.initial_backend_image_tag)) > 0
    error_message = "initial_backend_image_tag must not be empty."
  }
}

variable "initial_frontend_image_tag" {
  description = "Initial frontend image tag stored in SSM; application pipeline updates it later"
  type        = string
  default     = "frontend-2.0.1"

  validation {
    condition     = length(trimspace(var.initial_frontend_image_tag)) > 0
    error_message = "initial_frontend_image_tag must not be empty."
  }
}

variable "deployment_app_ssm_prefix" {
  description = "SSM Parameter Store prefix used by the deployment-notes app"
  type        = string
  default     = null

  validation {
    condition     = var.deployment_app_ssm_prefix == null || startswith(var.deployment_app_ssm_prefix, "/")
    error_message = "deployment_app_ssm_prefix must start with / when provided."
  }
}

variable "cloudwatch_log_group_prefix" {
  description = "CloudWatch Logs prefix for application and bootstrap logs"
  type        = string
  default     = null

  validation {
    condition     = var.cloudwatch_log_group_prefix == null || startswith(var.cloudwatch_log_group_prefix, "/")
    error_message = "cloudwatch_log_group_prefix must start with / when provided."
  }
}

variable "backend_container_name" {
  description = "Docker container name for the backend service."
  type        = string
  default     = "deployment-notes-backend"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]+$", var.backend_container_name))
    error_message = "backend_container_name must be a valid Docker container name."
  }
}

variable "frontend_container_name" {
  description = "Docker container name for the frontend service."
  type        = string
  default     = "deployment-notes-frontend"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]+$", var.frontend_container_name))
    error_message = "frontend_container_name must be a valid Docker container name."
  }
}

variable "backend_log_level" {
  description = "Log level passed to the backend container."
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"], upper(var.backend_log_level))
    error_message = "backend_log_level must be one of DEBUG, INFO, WARNING, ERROR, or CRITICAL."
  }
}

variable "backend_gunicorn_workers" {
  description = "Number of Gunicorn worker processes for the backend container."
  type        = number
  default     = 2

  validation {
    condition     = var.backend_gunicorn_workers >= 1
    error_message = "backend_gunicorn_workers must be at least 1."
  }
}

variable "backend_gunicorn_threads" {
  description = "Number of Gunicorn threads per backend worker."
  type        = number
  default     = 4

  validation {
    condition     = var.backend_gunicorn_threads >= 1
    error_message = "backend_gunicorn_threads must be at least 1."
  }
}

variable "container_health_check_attempts" {
  description = "Number of local container health check attempts during EC2 bootstrap."
  type        = number
  default     = 10

  validation {
    condition     = var.container_health_check_attempts >= 1
    error_message = "container_health_check_attempts must be at least 1."
  }
}

variable "container_health_check_interval_seconds" {
  description = "Seconds to wait between local container health check attempts during EC2 bootstrap."
  type        = number
  default     = 3

  validation {
    condition     = var.container_health_check_interval_seconds >= 1
    error_message = "container_health_check_interval_seconds must be at least 1."
  }
}

variable "web_desired_capacity" {
  description = "Desired capacity for the web Auto Scaling Group."
  type        = number
  default     = 2

  validation {
    condition     = var.web_desired_capacity >= 0
    error_message = "web_desired_capacity must be greater than or equal to 0."
  }
}

variable "app_desired_capacity" {
  description = "Desired capacity for the app Auto Scaling Group."
  type        = number
  default     = 2

  validation {
    condition     = var.app_desired_capacity >= 0
    error_message = "app_desired_capacity must be greater than or equal to 0."
  }
}

variable "db_engine_version" {
  description = "MySQL engine version for the RDS instance."
  type        = string
  default     = "8.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.db_engine_version))
    error_message = "db_engine_version must look like a MySQL version, for example 8.0."
  }
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GiB for the RDS instance."
  type        = number
  default     = 20

  validation {
    condition     = var.db_allocated_storage >= 20
    error_message = "db_allocated_storage must be at least 20 GiB for MySQL gp3."
  }
}

variable "db_max_allocated_storage" {
  description = "Upper storage autoscaling limit in GiB for the RDS instance."
  type        = number
  default     = 100

  validation {
    condition     = var.db_max_allocated_storage >= var.db_allocated_storage
    error_message = "db_max_allocated_storage must be greater than or equal to db_allocated_storage."
  }
}

variable "db_storage_type" {
  description = "Storage type for the RDS instance."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.db_storage_type)
    error_message = "db_storage_type must be one of gp2, gp3, io1, or io2."
  }
}

variable "database_name" {
  description = "Initial database name created by RDS."
  type        = string
  default     = "deployment_notes"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,63}$", var.database_name))
    error_message = "database_name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_master_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = "rhaast"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,15}$", var.db_master_username)) && !contains(["admin", "root"], lower(var.db_master_username))
    error_message = "db_master_username must be 1-16 characters, start with a letter, contain only letters, numbers, and underscores, and avoid reserved names."
  }
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ deployment for RDS."
  type        = bool
  default     = true
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated RDS backups."
  type        = number
  default     = 7

  validation {
    condition     = var.db_backup_retention_period >= 0 && var.db_backup_retention_period <= 35
    error_message = "db_backup_retention_period must be between 0 and 35 days."
  }
}

variable "db_deletion_protection" {
  description = "Whether deletion protection is enabled for the RDS instance."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip a final snapshot when destroying the RDS instance."
  type        = bool
  default     = true
}

variable "db_final_snapshot_identifier" {
  description = "Optional final snapshot identifier used when db_skip_final_snapshot is false."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.db_final_snapshot_identifier == null || can(regex("^[A-Za-z][A-Za-z0-9-]{0,254}$", var.db_final_snapshot_identifier))
    error_message = "db_final_snapshot_identifier must start with a letter and contain only letters, numbers, and hyphens."
  }
}

variable "db_apply_immediately" {
  description = "Whether RDS modifications are applied immediately instead of during the next maintenance window."
  type        = bool
  default     = true
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
