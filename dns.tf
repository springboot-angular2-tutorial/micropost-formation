resource "cloudflare_record" "foobar" {
  domain = "hana053.com"
  name = "micropost-${var.env}"
  value = "${aws_elb.web.dns_name}"
  type = "CNAME"
}