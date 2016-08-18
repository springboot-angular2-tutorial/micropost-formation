resource "aws_db_instance" "main" {
  snapshot_identifier = "${var.snapshot_identifier}"
  allocated_storage = 5
  engine = "mysql"
  engine_version = "5.7.10"
  instance_class = "db.t2.micro"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [
    "${var.security_groups}",
  ]
  db_subnet_group_name = "${aws_db_subnet_group.main.name}"
}

resource "aws_db_subnet_group" "main" {
  name = "main"
  description = "main group of subnets"
  subnet_ids = [
    "${var.subnets}"
  ]
}
