resource "aws_s3_bucket" "log" {
  bucket = "log-${var.env}.hana053.com"
  force_destroy = true
}
