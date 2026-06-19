variable "project" {
  description = "Project name used for resource names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name used for resource names and tags."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where security groups are created."
  type        = string
}

variable "web_port" {
  description = "Port exposed by web-tier instances."
  type        = number
  default     = 80

  validation {
    condition     = var.web_port >= 1 && var.web_port <= 65535
    error_message = "web_port must be between 1 and 65535."
  }
}

variable "app_port" {
  description = "Port exposed by app-tier instances."
  type        = number
  default     = 5000

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be between 1 and 65535."
  }
}

variable "db_port" {
  description = "Database port allowed from the app tier."
  type        = number
  default     = 3306

  validation {
    condition     = var.db_port >= 1 && var.db_port <= 65535
    error_message = "db_port must be between 1 and 65535."
  }
}
