provider "aws" {
  region = "${var.aws_region}"
}

provider "cloudflare" {
  email = ""
  token = ""
}