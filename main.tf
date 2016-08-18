module "vpc" {
  source = "./vpc"
  region = "${var.aws_region}"
}