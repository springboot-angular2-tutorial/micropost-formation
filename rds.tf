resource "aws_db_instance" "micropost" {
  snapshot_identifier = "micropost-init"
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = "5.7.10"
  instance_class       = "db.t2.micro"
  db_subnet_group_name = "${aws_db_subnet_group.micropost.name}"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [
    "${aws_security_group.internal.id}",
  ]
  tags {
    Name = "${var.app}-${var.env}"
    App = "${var.app}"
    Env = "${var.env}"
  }
}

resource "aws_db_subnet_group" "micropost" {
  name = "micropost-${var.env}"
  description = "Our main group of subnets"
  subnet_ids = ["${module.vpc.private_subnets}"]
}
