resource "cloudflare_record" "main" {
  domain = "${var.domain}"
  name = "${var.web_host_name}-${terraform.workspace}"
  value = "${module.webservers.dns_name}"
  type = "CNAME"
}

resource "cloudflare_record" "main_prod" {
  count = "${terraform.workspace == "prod" ? 1 : 0}"
  domain = "${var.domain}"
  name = "${var.web_host_name}"
  value = "${module.webservers.dns_name}"
  type = "CNAME"
}

resource "cloudflare_record" "cdn" {
  domain = "${var.domain}"
  name = "cdn-${terraform.workspace}"
  value = "${cloudflare_record.main.name}.hana053.com"
  proxied = true
  type = "CNAME"
}

