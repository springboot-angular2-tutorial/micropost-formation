resource "cloudflare_record" "micropost" {
  domain = "${var.domain}"
  name = "${var.web_host_name}"
  value = "${module.webservers.dns_name}"
  type = "CNAME"
}