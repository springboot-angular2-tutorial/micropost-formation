variable "min_scale_size" {
  default = 1
}

variable "desired_capacity" {
  default = 1
}

variable "env" {
  description = "Application environment like stg, prod eg..."
}

variable "hostname" {
  description = "web hostname"
}

variable "logserver_endpoint" {
  description = "Elastcsearch endpoint"
}

variable "dbserver_endpoint" {
  description = "MySQL endpoint"
}

variable "cacheserver_endpoint" {
  description = "Redis endpoint"
}

variable "deploy_bucket" {
  description = "Bucket to be used for deployment"
}

variable "deploy_bucket_arn" {
  description = "Bucket arn to be used for deployment"
}

variable "key_name" {
  description = "SSH key name for web servers"
}

variable "web_ami_tag" {
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

variable "alb_certificate_arn" {
  description = "alb certificate arn"
}

variable "vpc_id" {
  description = "vpc id for alb target group"
}

variable "log_bucket" {
  description = "s3 bucket to save log"
}
