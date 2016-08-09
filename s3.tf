resource "aws_s3_bucket" "web_codedeploy" {
  bucket = "deploy-${var.env}.hana053.com"
}
