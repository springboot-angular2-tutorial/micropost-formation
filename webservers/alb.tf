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
  access_logs {
    bucket = "${var.log_bucket}"
    prefix = "alb-web"
  }
}

// --------- frontend -----------

resource "aws_alb_target_group" "frontend" {
  name = "frontend"
  port = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
  health_check {
    interval = 30
    path = "/"
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }
}

// --------- backend -----------

resource "aws_alb_target_group" "backend" {
  name = "backend"
  port = 8080
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
  health_check {
    interval = 30
    path = "/manage/health"
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }
}

// --------- listeners -----------

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.frontend.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${data.aws_acm_certificate.main.arn}"
  default_action {
    target_group_arn = "${aws_alb_target_group.frontend.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener_rule" "backend" {
  listener_arn = "${aws_alb_listener.https.arn}"
  priority = 100
  condition {
    field = "path-pattern"
    values = [
      "/api/*"
    ]
  }
  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.backend.arn}"
  }
}
