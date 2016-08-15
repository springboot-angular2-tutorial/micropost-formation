resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
  tags {
    Name = "${var.app}-${var.env}"
    App = "${var.app}"
    Env = "${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.app}-${var.env}"
    App = "${var.app}"
    Env = "${var.env}"
  }
}

resource "aws_route_table" "public-route" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags {
    Name = "${var.app}-${var.env}"
    App = "${var.app}"
    Env = "${var.env}"
  }
}

// -------- public a

resource "aws_subnet" "public_primary" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.0.0/24"
  availability_zone = "${lookup(var.aws_az_primary, var.aws_region)}"
  tags {
    Name = "${var.app}-${var.env}-public1"
    App = "${var.app}"
    Env = "${var.env}"
  }
}

resource "aws_route_table_association" "puclic_primary" {
  subnet_id = "${aws_subnet.public_primary.id}"
  route_table_id = "${aws_route_table.public-route.id}"
}

// -------- public b

resource "aws_subnet" "public_secondary" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.1.0/24"
  availability_zone = "${lookup(var.aws_az_secondary, var.aws_region)}"
  tags {
    Name = "${var.app}-${var.env}-public2"
    App = "${var.app}"
    Env = "${var.env}"
  }
}

resource "aws_route_table_association" "puclic_secondary" {
  subnet_id = "${aws_subnet.public_secondary.id}"
  route_table_id = "${aws_route_table.public-route.id}"
}

// -------- private a

resource "aws_subnet" "private_primary" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.2.0/24"
  availability_zone = "${lookup(var.aws_az_primary, var.aws_region)}"
  tags {
    Name = "${var.app}-${var.env}-private3"
    App = "${var.app}"
    Env = "${var.env}"
  }
}

// -------- private b

resource "aws_subnet" "private_secondary" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.3.0/24"
  availability_zone = "${lookup(var.aws_az_secondary, var.aws_region)}"
  tags {
    Name = "${var.app}-${var.env}-private4"
    App = "${var.app}"
    Env = "${var.env}"
  }
}
