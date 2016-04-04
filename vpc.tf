resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
  tags {
    Name = "micropost"
    Env = "${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "public-route" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

// -------- public a

resource "aws_subnet" "public-a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags {
    Name = "public-a"
    Env = "${var.env}"
  }
}

resource "aws_route_table_association" "puclic-a" {
  subnet_id = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public-route.id}"
}

// -------- public b

resource "aws_subnet" "public-b" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags {
    Name = "public-b"
    Env = "${var.env}"
  }
}

resource "aws_route_table_association" "puclic-b" {
  subnet_id = "${aws_subnet.public-b.id}"
  route_table_id = "${aws_route_table.public-route.id}"
}

// -------- private a

resource "aws_subnet" "private-a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.3.0/24"
  availability_zone = "${var.aws_region}a"
  tags {
    Name = "private-a"
    Env = "${var.env}"
  }
}

// -------- private b

resource "aws_subnet" "private-b" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.4.0/24"
  availability_zone = "${var.aws_region}b"
  tags {
    Name = "private-b"
    Env = "${var.env}"
  }
}
