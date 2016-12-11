variable "env" {
  description = "Application environment like stg, prod eg..."
}

variable "dbserver_endpoint" {
  description = "MySQL endpoint"
}

variable "app_encryption_password" {
  description = "Applicatoin password to decrypt secret properties"
}

variable "newrelic_license_key" {
  description = "New Relic licence key"
}

variable "key_name" {
  description = "SSH key name for web servers"
}

variable "web_subnets" {
  type = "list"
  description = "Subnets for web servers"
  default = []
}

variable "web_security_groups" {
  type = "list"
  description = "Security groups for web servers"
  default = []
}

variable "alb_subnets" {
  type = "list"
  description = "Subnets for alb"
  default = []
}

variable "alb_security_groups" {
  type = "list"
  description = "Security groups for alb"
  default = []
}

variable "vpc_id" {
  description = "vpc id for alb target group"
}

variable "log_bucket" {
  description = "s3 bucket to save log"
}
