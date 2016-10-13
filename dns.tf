resource "cloudflare_record" "main" {
  domain = "${var.domain}"
  name = "${var.web_host_name}"
  value = "${module.webservers.dns_name}"
  type = "CNAME"
}

resource "cloudflare_record" "cdn" {
  domain = "${var.domain}"
  name = "cdn-${var.env}"
  value = "${aws_s3_bucket.cdn.bucket}.s3.amazonaws.com"
  type = "CNAME"
}
