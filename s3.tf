resource "aws_s3_bucket" "deploy" {
  bucket = "deploy-${var.env}.${var.domain}"
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
}

resource "aws_s3_bucket" "backup" {
  bucket = "backup-${var.env}.${var.domain}"
  force_destroy = true
}
