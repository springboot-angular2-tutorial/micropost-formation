variable "env" {
  description = "dev, stg, prod and etc."
  default = "dev"
}
variable "aws_account_num" {
}

variable "aws_region" {
  default = "ap-northeast-1"
}
variable "ami_web" {
}
variable "aws_az_primary" {
  default = {
    ap-southeast-1 = "ap-southeast-1a"
    ap-northeast-1 = "ap-northeast-1a"
  }
}
variable "aws_az_secondary" {
  default = {
    ap-southeast-1 = "ap-southeast-1b"
    ap-northeast-1 = "ap-northeast-1c"
  }
}

variable "cidr" {
  type = "map"
  default = {
    office = "42.116.5.4/32"
  }
}
