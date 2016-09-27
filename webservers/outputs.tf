output "dns_name" {
  value = "${aws_alb.web.dns_name}"
}

output "ami" {
  value = "${data.aws_ami.web.id}"
}

output "desired_capacity" {
  value = "${aws_autoscaling_group.web.desired_capacity}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.web.name}"
}

output "asg_id" {
  value = "${aws_autoscaling_group.web.id}"
}
