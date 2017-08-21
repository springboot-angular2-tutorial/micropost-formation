variable "allowed_segments" {
  type = "list"
  default = [
    "101.53.23.34/32",
  ]
}

variable "domain" {
  default = "hana053.com"
}

variable "web_host_name" {
  default = "micropost"
}

variable "newrelic_license_key" {
  description = "New Relic licence key"
}
