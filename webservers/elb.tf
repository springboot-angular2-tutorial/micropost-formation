resource "aws_elb" "web" {
  name = "web"
  subnets = [
    "${var.elb_subnets}"
  ]
  security_groups = [
    "${var.elb_security_groups}"
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
}

resource "aws_proxy_protocol_policy" "web" {
  load_balancer = "${aws_elb.web.name}"
  instance_ports = [
    "443"
  ]
}
