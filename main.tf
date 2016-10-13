provider "aws" {
  region = "${var.aws_region}"
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./vpc"
  name = "micropost"
}

module "webservers" {
  source = "./webservers"
  env = "${var.env}"
  logserver_endpoint = "${module.logservers.endpoint}"
  dbserver_endpoint = "${module.dbservers.endpoint}"
  deploy_bucket = "${aws_s3_bucket.deploy.bucket}"
  nginx_cdn_bucket = "${aws_s3_bucket.cdn.bucket}"
  key_name = "${aws_key_pair.micropost.key_name}"
  web_ami_tag = "micropost-web"
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
  alb_certificate_arn = "${var.alb_certificate_arn}"
  min_scale_size = "${var.web_min_size}"
  desired_capacity = "${var.web_desired_capacity}"
  vpc_id = "${module.vpc.vpc_id}"
  log_bucket = "${aws_s3_bucket.log.bucket}"
}

module "cdn" {
  source = "./cdn"
  domain = "${var.web_host_name}.${var.domain}"
  certificate_arn = "${var.cf_certificate_arn}"
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

module "logservers" {
  source = "./logservers"
  aws_region = "${var.aws_region}"
  allowed_segments = "${var.allowed_segments}"
  backup_repository = "micropost-log-backups"
  backup_backet = "${aws_s3_bucket.backup.bucket}"
  backup_backet_arn = "${aws_s3_bucket.backup.arn}"
}

module "web_codedeploy" {
  source = "./codedeploy"
  name = "micropost"
  group_name = "web"
  autoscaling_groups = ["${module.webservers.asg_id}"]
}

module "security_groups" {
  source = "./security_groups"
  vpc_id = "${module.vpc.vpc_id}"
  ssh_allowed_segments = ["${var.allowed_segments}"]
}
