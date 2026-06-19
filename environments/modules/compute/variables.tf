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

variable "web_subnet_ids" {
  description = "Subnet IDs used by the web Auto Scaling Group."
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Subnet IDs used by the app Auto Scaling Group."
  type        = list(string)
}

variable "web_security_group_id" {
  description = "Security group ID attached to web EC2 instances."
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID attached to app EC2 instances."
  type        = string
}

variable "web_target_group_arn" {
  description = "Target group ARN where web instances register."
  type        = string
}

variable "app_target_group_arn" {
  description = "Target group ARN where app instances register."
  type        = string
}

variable "database_host" {
  description = "RDS database hostname used by the backend application."
  type        = string
}

variable "database_port" {
  description = "RDS database port used by the backend application."
  type        = number
  default     = 3306

  validation {
    condition     = var.database_port >= 1 && var.database_port <= 65535
    error_message = "database_port must be between 1 and 65535."
  }
}

variable "database_name" {
  description = "Database name used by the backend application."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,63}$", var.database_name))
    error_message = "database_name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "database_username" {
  description = "Database username stored in the backend runtime DB config parameter."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,15}$", var.database_username))
    error_message = "database_username must be 1-16 characters, start with a letter, and contain only letters, numbers, and underscores."
  }
}

variable "database_secret_arn" {
  description = "ARN of the AWS-managed RDS master user secret used by the backend application."
  type        = string

  validation {
    condition     = can(regex("^arn:[^:]+:secretsmanager:[^:]+:[0-9]+:secret:.+$", var.database_secret_arn))
    error_message = "database_secret_arn must be a valid Secrets Manager secret ARN."
  }
}

variable "internal_alb_dns_name" {
  description = "Private DNS name used by the web tier to reach the app tier."
  type        = string
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
}

variable "initial_frontend_image_tag" {
  description = "Initial frontend image tag stored in SSM; application pipeline updates it later"
  type        = string
  default     = "frontend-2.0.1"
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch log groups created by instance bootstrap."
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.cloudwatch_log_retention_days)
    error_message = "cloudwatch_log_retention_days must be one of the CloudWatch Logs retention values supported by AWS."
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

variable "instance_type" {
  description = "EC2 instance type for web and app instances."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9a-z]*\\.[a-z0-9]+$", var.instance_type))
    error_message = "instance_type must look like an EC2 instance type, for example t3.micro."
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

variable "min_size" {
  description = "Minimum size shared by the web and app Auto Scaling Groups."
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 0
    error_message = "min_size must be greater than or equal to 0."
  }
}

variable "max_size" {
  description = "Maximum size shared by the web and app Auto Scaling Groups."
  type        = number
  default     = 4

  validation {
    condition     = var.max_size >= 1
    error_message = "max_size must be greater than or equal to 1."
  }
}

variable "app_port" {
  description = "Port exposed by the backend application container."
  type        = number
  default     = 5000

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be between 1 and 65535."
  }
}

check "autoscaling_capacity_bounds" {
  assert {
    condition     = var.min_size <= var.max_size
    error_message = "min_size must be less than or equal to max_size."
  }

  assert {
    condition     = var.web_desired_capacity >= var.min_size && var.web_desired_capacity <= var.max_size
    error_message = "web_desired_capacity must be between min_size and max_size."
  }

  assert {
    condition     = var.app_desired_capacity >= var.min_size && var.app_desired_capacity <= var.max_size
    error_message = "app_desired_capacity must be between min_size and max_size."
  }
}
