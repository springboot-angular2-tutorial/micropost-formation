variable "web_min_size" {
  default = 1
}

variable "web_desired_capacity" {
  default = 1
}

data "aws_ami" "web" {
  most_recent = true
  owners = [
    "self"]

  filter {
    name = "tag:Name"
    values = [
      "micropost-web"]
  }
}

data "template_file" "web_init" {
  template = "${file("templates/web_init.sh")}"
  vars {
    env = "${var.env}"
    logserver_endpoint = "${aws_elasticsearch_domain.micropost.endpoint}"
    rds_endpoint = "${aws_db_instance.micropost.endpoint}"
    redis_endpoint = "${aws_elasticache_cluster.micropost.cache_nodes.0.address}"
    web_endpoint = "${cloudflare_record.micropost.hostname}"
    s3_deploy_bucket = "${aws_s3_bucket.deploy.bucket}"
  }
}

resource "aws_launch_configuration" "web" {
  name_prefix = "web-${var.env}-"
  image_id = "${data.aws_ami.web.id}"
  instance_type = "t2.micro"
  security_groups = [
    "${aws_security_group.internal.id}",
  ]
  key_name = "${aws_key_pair.micropost.key_name}"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.web.id}"
  user_data = "${data.template_file.web_init.rendered}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "web-${var.env}"
  launch_configuration = "${aws_launch_configuration.web.id}"
  max_size = 4
  min_size = "${var.web_min_size}"
  desired_capacity = "${var.web_desired_capacity}"
  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  vpc_zone_identifier = ["${module.vpc.public_subnets}"]
  load_balancers = [
    "${aws_elb.web.name}"]
  tag {
    key = "Name"
    value = "${var.app}-${var.env}-web"
    propagate_at_launch = true
  }
  tag {
    key = "App"
    value = "${var.app}"
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
  name = "Instance-ScaleOut-CPU-High"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web_gte_threshold" {
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
  alarm_actions = [
    "${aws_autoscaling_policy.web_scale_out.arn}"]
}

resource "aws_autoscaling_policy" "web_scale_in" {
  name = "Instance-ScaleIn-CPU-Low"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web_lt_threshold" {
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
  alarm_actions = [
    "${aws_autoscaling_policy.web_scale_in.arn}"]
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.app}-${var.env}-web"
  roles = [
    "${aws_iam_role.web.name}"
  ]
}

resource "aws_iam_role" "web" {
  name = "${var.app}-${var.env}-web"
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

resource "aws_iam_role_policy" "es_client" {
  name = "es-client"
  role = "${aws_iam_role.web.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "es:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "letsencrypt_cache_client" {
  name = "letsencrypt-cache-client"
  role = "${aws_iam_role.web.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:Put*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.deploy.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codedeploy_client" {
  name = "codedeploy-client"
  role = "${aws_iam_role.web.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.deploy.arn}/*"
    }
  ]
}
EOF
}

resource "aws_elb" "web" {
  name = "${var.app}-${var.env}-web"
  subnets = ["${module.vpc.public_subnets}"]
  security_groups = [
    "${aws_security_group.internal.id}",
    "${aws_security_group.http.id}",
    "${aws_security_group.https.id}",
  ]
  // use for health check
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:80/manage/health"
    interval = 30
  }
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  tags {
    Name = "${var.app}-${var.env}-web"
    App = "${var.app}"
    Env = "${var.env}"
    Role = "web"
  }
}

resource "aws_proxy_protocol_policy" "web" {
  load_balancer = "${aws_elb.web.name}"
  instance_ports = [
    "443"]
}
