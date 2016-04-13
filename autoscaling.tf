resource "template_file" "web_init" {
  template = "${file("templates/web_init.sh")}"
  vars {
    env = "${var.env}"
    logserver_endpoint = "${aws_elasticsearch_domain.logserver.endpoint}"
    rds_endpoint = "${aws_db_instance.micropost.endpoint}"
    redis_endpoint = "${aws_elasticache_cluster.micropost.cache_nodes.0.address}:${aws_elasticache_cluster.micropost.cache_nodes.0.port}"
    web_endpoint = "${cloudflare_record.micropost.hostname}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "web" {
  name_prefix = "web-${var.env}-"
  image_id = "${var.ami_web}"
  instance_type = "t2.micro"
  security_groups = [
    "${aws_security_group.internal.id}",
    "${aws_security_group.ssh.id}",
  ]
  key_name = "id_rsa"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.web.id}"
  user_data = "${template_file.web_init.rendered}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "web-${var.env}"
  max_size = 4
  min_size = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 1
  force_delete = true
  launch_configuration = "${aws_launch_configuration.web.id}"
  vpc_zone_identifier = [
    "${aws_subnet.public_primary.id}",
    "${aws_subnet.public_secondary.id}",
  ]
  load_balancers = ["${aws_elb.web.name}"]
}

resource "aws_autoscaling_policy" "web-scale-out" {
  name = "Instance-ScaleOut-CPU-High"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web-gte-threshold" {
  alarm_name = "web-${var.env}-CPU-Utilization-High-30"
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
  alarm_actions = ["${aws_autoscaling_policy.web-scale-out.arn}"]
}

resource "aws_autoscaling_policy" "web-scale-in" {
  name = "Instance-ScaleIn-CPU-Low"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web-lt-threshold" {
  alarm_name = "web-${var.env}-CPU-Utilization-Low-5"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "5"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }
  alarm_actions = ["${aws_autoscaling_policy.web-scale-in.arn}"]
}
