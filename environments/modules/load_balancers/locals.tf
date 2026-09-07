locals {
  name_prefix                   = "${var.project}-${var.environment}"
  alb_access_logs_object_prefix = trim(var.alb_access_logs.object_prefix, "/")

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
