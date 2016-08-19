resource "aws_vpc" "main" {
  cidr_block = "${var.cidr}"
  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "public" {
  count = "${length(var.public_subnets)}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "puclic" {
  count = "${length(var.public_subnets)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "private" {
  count = "${length(var.public_subnets)}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  tags {
    Name = "${var.name}-private"
  }
}

