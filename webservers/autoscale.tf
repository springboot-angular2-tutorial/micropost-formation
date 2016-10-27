data "aws_ami" "web" {
  most_recent = true
  owners = [
    "self"
  ]
  filter {
    name = "tag:Name"
    values = [
      "${var.web_ami_tag}"
    ]
  }
}

data "template_file" "web_init" {
  template = "${file("./webservers/web_init.sh")}"
  vars {
    env = "${var.env}"
    dbserver_endpoint = "${var.dbserver_endpoint}"
    deploy_bucket = "${var.deploy_bucket}"
    nginx_cdn_bucket = "${var.nginx_cdn_bucket}"
  }
}

resource "aws_launch_configuration" "web" {
  name_prefix = "web-"
  image_id = "${data.aws_ami.web.id}"
  instance_type = "t2.micro"
  security_groups = [
    "${var.web_security_groups}"
  ]
  key_name = "${var.key_name}"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.web.id}"
  user_data = "${data.template_file.web_init.rendered}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "web"
  launch_configuration = "${aws_launch_configuration.web.id}"
  max_size = 2
  min_size = "${var.min_scale_size}"
  desired_capacity = "${var.desired_capacity}"
  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  vpc_zone_identifier = [
    "${var.web_subnets}"
  ]
  target_group_arns = [
    "${aws_alb_target_group.api.arn}",
    "${aws_alb_target_group.index.arn}"
  ]
  tag {
    key = "Name"
    value = "${var.env}-web"
    propagate_at_launch = true
  }
  tag {
    key = "Env"
    value = "${var.env}"
    propagate_at_launch = true
  }
  tag {
    key = "Role"
    value = "web"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "web_scale_out" {
  name = "web-Instance-ScaleOut-CPU-High"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web_gte_threshold" {
  alarm_name = "web-CPU-Utilization-High-80"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "80"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }
  alarm_actions = [
    "${aws_autoscaling_policy.web_scale_out.arn}"
  ]
}

resource "aws_autoscaling_policy" "web_scale_in" {
  name = "web-Instance-ScaleIn-CPU-Low"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web_lt_threshold" {
  alarm_name = "web-CPU-Utilization-Low-5"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "5"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }
  alarm_actions = [
    "${aws_autoscaling_policy.web_scale_in.arn}"
  ]
}

