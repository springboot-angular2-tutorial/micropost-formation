resource "aws_elb" "web" {
  name = "web-${var.env}"
  subnets = [
    "${aws_subnet.public-a.id}",
    "${aws_subnet.public-b.id}",
  ]
  security_groups = [
    "${aws_security_group.internal.id}",
    "${aws_security_group.http.id}",
  ]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
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
