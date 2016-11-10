data "aws_acm_certificate" "main" {
  domain = "*.hana053.com"
  statuses = ["ISSUED"]
}

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
    bucket = "${var.log_bucket}"
    prefix = "alb-web"
  }
}

resource "aws_alb_target_group" "api" {
  name = "api"
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

resource "aws_alb_target_group" "index" {
  name = "index"
  port = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
  health_check {
    interval = 30
    path = "/"
    port = 80
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${data.aws_acm_certificate.main.arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.index.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener_rule" "api" {
  listener_arn = "${aws_alb_listener.https.arn}"
  priority = 100
  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.api.arn}"
  }
  condition {
    field = "path-pattern"
    values = [
      "/api/*"
    ]
  }
}

resource "aws_alb_listener_rule" "index" {
  listener_arn = "${aws_alb_listener.https.arn}"
  priority = 9999
  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.index.arn}"
  }
  condition {
    field = "path-pattern"
    values = [
      "*"
    ]
  }
}
