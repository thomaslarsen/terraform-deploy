data "null_data_source" "subnet" {
# Calculate the VPC subnet octets
  inputs = {
    subnet_1 = "10.${var.octet2}.${var.octet3 + var.slot / 2}.${(var.slot * 128) % 256}/${var.size}"
    subnet_2 = "10.${var.octet2}.${var.octet3 + var.slot / 2}.${((var.slot * 128) % 256) + 64}/${var.size}"
  }
}

data "null_data_source" "azs" {
# Calculate the VPC subnet octets
  inputs = {
    subnet_1 = "${var.region}a"
    subnet_2 = "${var.region}b"
    subnet_3 = "${var.region}c"
  }
}

resource "aws_subnet" "subnet" {
  count = 2
  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(values(data.null_data_source.subnet.inputs), count.index)}"
  availability_zone = "${element(values(data.null_data_source.azs.inputs), count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip}"

  tags = {
    Name = "sn-${var.name}-${element(values(data.null_data_source.azs.inputs), count.index)}"
  }
}

resource "aws_route_table_association" "rt" {
  count = 2
  subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${var.route_table_id}"
}
