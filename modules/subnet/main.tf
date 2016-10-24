
resource "aws_subnet" "subnet-az-a" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.${var.octet2}.${var.octet3 + var.slot / 2}.${(var.slot * 128) % 256}/${var.size}"
  availability_zone = "${var.az_a}"

  tags = {
    Name = "sn-${var.name}-${var.az_a}"
  }
}

resource "aws_route_table_association" "rt-az-a" {
  subnet_id = "${aws_subnet.subnet-az-a.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_subnet" "subnet-az-b" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.${var.octet2}.${var.octet3 + var.slot / 2}.${((var.slot * 128) % 256) + 64}/${var.size}"
  availability_zone = "${var.az_b}"

  tags = {
    Name = "sn-${var.name}-${var.az_b}"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "rt-az-b" {
  subnet_id = "${aws_subnet.subnet-az-b.id}"
  route_table_id = "${var.route_table_id}"
}
