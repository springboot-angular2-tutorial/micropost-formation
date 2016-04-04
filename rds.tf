resource "aws_db_instance" "micropost" {
  identifier = "micropost-${var.env}"
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
}

resource "aws_db_subnet_group" "micropost" {
  name = "micropost-${var.env}"
  description = "Our main group of subnets"
  subnet_ids = [
    "${aws_subnet.private-a.id}",
    "${aws_subnet.private-b.id}",
  ]
}
