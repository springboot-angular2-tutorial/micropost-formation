provider "aws" {
  region = "${var.aws_region}"
}

module "vpc" {
  source = "./vpc"
  region = "${var.aws_region}"
}

module "webservers" {
  source = "./webservers"
  env = "${var.env}"
  hostname = "${cloudflare_record.micropost.hostname}"
  logserver_endpoint = "${module.logservers.endpoint}"
  dbserver_endpoint = "${module.dbservers.endpoint}"
  cacheserver_endpoint = "${module.cacheservers.endpoint}"
  deploy_bucket = "${aws_s3_bucket.deploy.bucket}"
  deploy_bucket_arn = "${aws_s3_bucket.deploy.arn}"
  key_name = "${aws_key_pair.micropost.key_name}"
  web_subnets = [
    "${module.vpc.public_subnets}"
  ]
  web_security_groups = [
    "${aws_security_group.internal.id}",
  ]
  elb_subnets = [
    "${module.vpc.public_subnets}"
  ]
  elb_security_groups = [
    "${aws_security_group.internal.id}",
    "${aws_security_group.http.id}",
    "${aws_security_group.https.id}",
  ]
  min_scale_size = "${var.web_min_size}"
  desired_capacity = "${var.web_desired_capacity}"
}

module "bastion" {
  source = "./bastion"
  subnet_id = "${module.vpc.public_subnets[0]}"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.internal.id}",
  ]
  key_name = "${aws_key_pair.micropost.key_name}"
}

module "cacheservers" {
  source = "./cacheservers"
  security_groups = [
    "${aws_security_group.internal.id}",
  ]
  subnets = [
    "${module.vpc.private_subnets}",
  ]
}

module "dbservers" {
  source = "./dbservers"
  security_groups = [
    "${aws_security_group.internal.id}",
  ]
  subnets = [
    "${module.vpc.private_subnets}",
  ]
  snapshot_identifier = "micropost-init"
}

module "logservers" {
  source = "./logservers"
  aws_account_id = "${var.aws_account_id}"
  aws_region = "${var.aws_region}"
  allowed_segments = "${var.allowed_segments}"
  backup_repository = "micropost-log-backups"
  backup_backet = "${aws_s3_bucket.backup.bucket}"
  backup_backet_arn = "${aws_s3_bucket.backup.arn}"
}