variable "env" {
  description = "dev, stg, prod and etc."
}

variable "aws_region" {
  default = "ap-northeast-1"
}

variable "aws_role_arn" {
  default = ""
}

variable "allowed_segments" {
  type = "list"
  default = [
    "42.116.5.4/32",
    "118.69.191.34/32"
  ]
}

variable "domain" {
  default = "hana053.com"
}

variable "alb_certificate_arn" {
  description = "ACM certificate arn for ALB"
}

variable "web_host_name" {
}

variable "web_min_size" {
  default = 1
}

variable "web_desired_capacity" {
  default = 1
}
