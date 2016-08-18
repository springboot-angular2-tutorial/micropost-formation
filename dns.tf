resource "cloudflare_record" "micropost" {
  domain = "hana053.com"
  name = "${var.web_host_name}"
  value = "${module.webservers.dns_name}"
  type = "CNAME"
}