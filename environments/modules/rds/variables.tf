variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "database_name" {
  type    = string
  default = "deployment_notes"
}

variable "master_username" {
  type    = string
  default = "rhaast"
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}
