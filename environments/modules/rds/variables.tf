variable "project" {
  description = "Project name used for resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name used for resource names and tags."
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group used by the RDS instance."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to the RDS instance."
  type        = string
}

variable "engine" {
  description = "Database engine used by the RDS instance."
  type        = string
  default     = "mysql"

  validation {
    condition     = var.engine == "mysql"
    error_message = "Only mysql is supported by this demo application."
  }
}

variable "engine_version" {
  description = "MySQL engine version for the RDS instance."
  type        = string
  default     = "8.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+", var.engine_version))
    error_message = "engine_version must look like a MySQL version, for example 8.0."
  }
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.instance_class))
    error_message = "instance_class must look like an RDS instance class, for example db.t3.micro."
  }
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB for the RDS instance."
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "allocated_storage must be at least 20 GiB for MySQL gp3."
  }
}

variable "max_allocated_storage" {
  description = "Upper storage autoscaling limit in GiB for the RDS instance."
  type        = number
  default     = 100

  validation {
    condition     = var.max_allocated_storage >= var.allocated_storage
    error_message = "max_allocated_storage must be greater than or equal to allocated_storage."
  }
}

variable "storage_type" {
  description = "Storage type for the RDS instance."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.storage_type)
    error_message = "storage_type must be one of gp2, gp3, io1, or io2."
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

variable "master_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = "deployment_admin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,15}$", var.master_username)) && !contains(["admin", "root"], lower(var.master_username))
    error_message = "master_username must be 1-16 characters, start with a letter, contain only letters, numbers, and underscores, and avoid reserved names."
  }
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment for RDS."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Number of days to retain automated RDS backups."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 0 and 35 days."
  }
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the RDS instance."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot when destroying the RDS instance."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Optional final snapshot identifier used when skip_final_snapshot is false."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.final_snapshot_identifier == null || can(regex("^[A-Za-z][A-Za-z0-9-]{0,254}$", var.final_snapshot_identifier))
    error_message = "final_snapshot_identifier must start with a letter and contain only letters, numbers, and hyphens."
  }
}

variable "apply_immediately" {
  description = "Whether RDS modifications are applied immediately instead of during the next maintenance window."
  type        = bool
  default     = true
}
