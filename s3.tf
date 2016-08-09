resource "aws_s3_bucket" "deploy" {
  bucket = "deploy-${var.env}.hana053.com"
  force_destroy = true
}
