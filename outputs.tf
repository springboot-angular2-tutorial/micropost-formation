output "web_ami" {
  value = "${data.aws_ami.micropost_web.id}"
}

output "web_desired_capacity" {
  value = "${aws_autoscaling_group.web.desired_capacity}"
}

output "web_autoscaling_group_name" {
  value = "${aws_autoscaling_group.web.name}"
}
