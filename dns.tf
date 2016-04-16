resource "cloudflare_record" "micropost" {
  domain = "hana053.com"
  name = "${var.web_host_name}"
  value = "${aws_elb.web.dns_name}"
  type = "CNAME"
}