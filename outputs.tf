output "ami_web" {
  value = "${aws_launch_configuration.web.image_id}"
}

output "web_desired_capacity" {
  value = "${aws_autoscaling_group.web.desired_capacity}"
}