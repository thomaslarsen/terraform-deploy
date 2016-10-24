resource "aws_route_table" "instance" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${var.instance_id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
