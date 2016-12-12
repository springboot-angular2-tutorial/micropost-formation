data "aws_ami" "ecs" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

data "template_file" "user_data" {
  template = "${file("./webservers/user_data.sh")}"
  vars {
    cluster_name = "${aws_ecs_cluster.main.name}"
    newrelic_license_key  = "${var.newrelic_license_key}"
  }
}

resource "aws_launch_configuration" "web" {
  name_prefix = "web-"
  image_id = "${data.aws_ami.ecs.id}"
  instance_type = "t2.micro"
  security_groups = [
    "${var.web_security_groups}"
  ]
  key_name = "${var.key_name}"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.web.id}"
  user_data = "${data.template_file.user_data.rendered}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "web"
  launch_configuration = "${aws_launch_configuration.web.id}"
  max_size = 2
  min_size = 1
  health_check_type = "ELB"
  force_delete = true
  vpc_zone_identifier = [
    "${var.web_subnets}"
  ]
  target_group_arns = [
    "${aws_alb_target_group.backend.arn}",
    "${aws_alb_target_group.frontend.arn}"
  ]
}

// ------ scale out -------

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
  namespace = "AWS/ECS"
  period = "120"
  statistic = "Average"
  threshold = "80"
  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
  alarm_actions = [
    "${aws_autoscaling_policy.web_scale_out.arn}"
  ]
}

// ------ scale in -------

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
  namespace = "AWS/ECS"
  period = "60"
  statistic = "Average"
  threshold = "5"
  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }
  alarm_actions = [
    "${aws_autoscaling_policy.web_scale_in.arn}"
  ]
}

// ------ notification -------

resource "aws_autoscaling_notification" "web" {
  group_names = [
    "${aws_autoscaling_group.web.name}",
  ]
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
  ]
  topic_arn = "arn:aws:sns:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:web_autoscaled"
}

// ------ iam -------

resource "aws_iam_instance_profile" "web" {
  name = "web"
  roles = [
    "${aws_iam_role.web.name}"
  ]
}

resource "aws_iam_role" "web" {
  name = "web"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_host" {
  name = "ecs-host"
  roles = ["${aws_iam_role.web.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

