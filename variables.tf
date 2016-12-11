variable "env" {
  description = "dev, stg, prod and etc."
}

variable "allowed_segments" {
  type = "list"
  default = [
    "42.116.5.4/32",
    "119.15.185.149/32",
  ]
}

variable "domain" {
  default = "hana053.com"
}

variable "web_host_name" {
}

variable "app_encryption_password" {
  description = "Applicatoin password to decrypt secret properties"
}

variable "newrelic_license_key" {
  description = "New Relic licence key"
}
