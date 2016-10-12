resource "cloudflare_record" "frontend" {
  domain = "${var.domain}"
  name = "${var.web_host_name}"
  value = "${module.cdn.domain_name}"
  type = "CNAME"
}

resource "cloudflare_record" "backend" {
  domain = "${var.domain}"
  name = "backend-${var.env}"
  value = "${module.webservers.dns_name}"
  type = "CNAME"
}