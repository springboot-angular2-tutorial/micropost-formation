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
}
