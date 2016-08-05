// stateless variables

variable "env" {
  description = "dev, stg, prod and etc."
  default = "dev"
}
variable "aws_account_num" {
}
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "web_host_name" {
}

// stateful variables

variable "web_desired_capacity" {
  default = 1
}
