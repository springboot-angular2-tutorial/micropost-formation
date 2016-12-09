resource "cloudflare_record" "main" {
  domain = "${var.domain}"
  name = "${var.web_host_name}"
  value = "${module.webservers.dns_name}"
  type = "CNAME"
}

resource "cloudflare_record" "cdn" {
  domain = "${var.domain}"
  name = "cdn-${var.env}"
  value = "${var.web_host_name}.hana053.com"
  proxied = true
  type = "CNAME"
}
