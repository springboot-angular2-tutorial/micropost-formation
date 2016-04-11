variable "env" {
  description = "dev, stg, prod and etc."
  default = "dev"
}
variable "aws_account_num" {
}
variable "aws_region" {
  default = "ap-southeast-1"
}
variable "ami_web" {
  default = "ami-25c00c46"
}
variable "cidr" {
  type = "map"
  default = {
    office = "42.116.5.4/32"
  }
}

variable "desired_capacity_web" {
  default = 1
}
