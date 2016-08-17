resource "aws_s3_bucket" "deploy" {
  bucket = "deploy-${var.env}.hana053.com"
  force_destroy = true
  // evict letsencrypt cert
  lifecycle_rule {
    id = "cert"
    prefix = "cert/"
    enabled = true
    expiration {
      days = 20
    }
  }
  tags {
    Name = "${var.app}-${var.env}"
    App = "${var.app}"
    Env = "${var.env}"
  }
}

resource "aws_s3_bucket" "backup" {
  bucket = "backup-${var.env}.hana053.com"
  force_destroy = true
}
