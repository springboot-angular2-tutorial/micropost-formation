resource "aws_elb" "web" {
  name = "web-${var.env}"
  subnets = [
    "${aws_subnet.public_primary.id}",
    "${aws_subnet.public_secondary.id}",
  ]
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
}

resource "aws_proxy_protocol_policy" "web" {
  load_balancer = "${aws_elb.web.name}"
  instance_ports = ["443"]
}