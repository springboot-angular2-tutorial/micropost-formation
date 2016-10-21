resource "aws_sns_topic" "backend_app_updated" {
  name = "backend_app_updated"
}

resource "aws_sns_topic" "asg_image_updated" {
  name = "asg_image_updated"
}
