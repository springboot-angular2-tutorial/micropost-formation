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

// stateful variables

variable "web_ami" {
}
variable "web_desired_capacity" {
  default = 1
}
