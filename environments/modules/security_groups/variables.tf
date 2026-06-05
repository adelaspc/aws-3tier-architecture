variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "web_port" {
  type    = number
  default = 80
}

variable "app_port" {
  type    = number
  default = 5000
}

variable "db_port" {
  type    = number
  default = 3306
}