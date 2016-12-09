output "dns_name" {
  value = "${aws_alb.web.dns_name}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.web.name}"
}
