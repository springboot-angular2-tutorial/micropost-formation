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

variable "segment" {
  default = {
    office = "42.116.5.4/32"
  }
}
