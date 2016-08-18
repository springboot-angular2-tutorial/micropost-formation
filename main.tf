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
  logserver_endpoint = "${aws_elasticsearch_domain.micropost.endpoint}"
  dbserver_endpoint = "${aws_db_instance.micropost.endpoint}"
  cacheserver_endpoint = "${aws_elasticache_cluster.micropost.cache_nodes.0.address}"
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
}