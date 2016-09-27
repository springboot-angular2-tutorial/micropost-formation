variable "env" {
  description = "dev, stg, prod and etc."
  default = "dev"
}

variable "aws_region" {
  default = "ap-northeast-1"
}

variable "allowed_segments" {
  default = [
    "42.116.5.4/32",
  ]
}

variable "domain" {
  default = "hana053.com"
}

variable "web_host_name" {
}

variable "web_min_size" {
  default = 1
}

variable "web_desired_capacity" {
  default = 1
}
