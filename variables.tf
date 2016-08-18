variable "env" {
  description = "dev, stg, prod and etc."
  default = "dev"
}
variable "aws_account_id" {
}
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "web_host_name" {
}

variable "app" {
  default = "micropost"
}

variable "allowed_segments" {
  default = [
    "42.116.5.4/32",
    "171.232.52.48/32",
  ]
}

variable "web_min_size" {
  default = 1
}

variable "web_desired_capacity" {
  default = 1
}
