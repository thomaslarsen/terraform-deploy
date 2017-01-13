variable "vpc_id" {

}

variable "name" {

}

variable "description" {
  default = "Security Group managed by Terraform"
}

resource "aws_security_group" "sg" {
  vpc_id = "${var.vpc_id}"

  description = "${var.description}"
  name = "${var.name}"

  tags {
    Name = "sg-${var.name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_id" {
  value = "${aws_security_group.sg.id}"
}
