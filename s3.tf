resource "aws_s3_bucket" "web_codedeploy" {
  bucket = "web-condedeploy-${var.env}.hana053.com"
  region = "${var.aws_region}"
}