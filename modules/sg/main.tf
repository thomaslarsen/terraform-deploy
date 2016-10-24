variable "vpc_id" {

}

variable "name" {

}

resource "aws_security_group" "sg" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_id" {
  value = "${aws_security_group.sg.id}"
}
