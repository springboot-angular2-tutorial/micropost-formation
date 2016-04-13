output "ami_web" {
  value = "${aws_launch_configuration.web.image_id}"
}
