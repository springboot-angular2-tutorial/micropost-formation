variable "name" {
}

variable "cidr" {
  default = "10.1.0.0/16"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC."
  default = [
    "10.1.0.0/24",
    "10.1.1.0/24",
  ]
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC."
  default = [
    "10.1.2.0/24",
    "10.1.3.0/24",
  ]
}

variable "azs" {
  description = "A list of Availability zones in the region"
  default = [
    "ap-northeast-1a",
    "ap-northeast-1c",
  ]
}
