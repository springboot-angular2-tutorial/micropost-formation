provider "aws" {
  region = "ap-northeast-1"
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./vpc"
  name = "micropost"
}

module "webservers" {
  source = "./webservers"
  env = "${var.env}"
  dbserver_endpoint = "${module.dbservers.endpoint}"
  app_encryption_password = "${var.app_encryption_password}"
  newrelic_license_key = "${var.newrelic_license_key}"
  key_name = "${aws_key_pair.micropost.key_name}"
  web_subnets = [
    "${module.vpc.public_subnets}"
  ]
  web_security_groups = [
    "${module.security_groups.internal}",
  ]
  alb_subnets = [
    "${module.vpc.public_subnets}"
  ]
  alb_security_groups = [
    "${module.security_groups.internal}",
    "${module.security_groups.internet_in_http}",
    "${module.security_groups.internet_in_https}",
  ]
  vpc_id = "${module.vpc.vpc_id}"
  log_bucket = "${aws_s3_bucket.log.bucket}"
}

//module "bastion" {
//  source = "./bastion"
//  subnet_id = "${module.vpc.public_subnets[0]}"
//  security_groups = [
//    "${module.security_groups.internal}",
//    "${module.security_groups.internet_in_ssh}",
//  ]
//  key_name = "${aws_key_pair.micropost.key_name}"
//}

module "dbservers" {
  source = "./dbservers"
  security_groups = [
    "${module.security_groups.internal}",
  ]
  subnets = [
    "${module.vpc.private_subnets}",
  ]
  snapshot_identifier = "micropost-init"
}

module "security_groups" {
  source = "./security_groups"
  vpc_id = "${module.vpc.vpc_id}"
  ssh_allowed_segments = ["${var.allowed_segments}"]
}
