resource "aws_alb" "web" {
  name = "web"
  internal = false
  security_groups = [
    "${var.alb_security_groups}"
  ]
  subnets = [
    "${var.alb_subnets}"
  ]
  enable_deletion_protection = true
  access_logs {
    bucket = "${aws_s3_bucket.log.bucket}"
    prefix = "alb-web"
  }
}

resource "aws_alb_target_group" "web" {
  name = "web"
  port = 8080
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
  health_check {
    interval = 30
    path = "/manage/health"
    port = 8080
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }
}

resource "aws_alb_listener" "web" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${var.alb_certificate_arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.web.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener_rule" "web" {
  listener_arn = "${aws_alb_listener.web.arn}"
  priority = 100
  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.web.arn}"
  }
  condition {
    field = "path-pattern"
    values = [
      "*"
    ]
  }
}