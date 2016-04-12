resource "aws_s3_bucket" "web_codedeploy" {
  bucket = "web-condedeploy-${var.env}.hana053.com"
  force_destroy = true
}
