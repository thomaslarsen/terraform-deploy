variable "sg_id" {

}

variable "type" {
  description = "Ingress or egress"
  default = "ingress"
}

variable "protocol" {
  default = "all"
}

variable "source_cidr" {
  type = "list"
  default = ["0.0.0.0/0"]
}

variable "from_port" {
  default = "0"
}

variable "to_port" {
  default = "65535"
}

resource "aws_security_group_rule" "sg_rule" {
  type = "${var.type}"
  from_port = "${var.from_port}"
  to_port = "${var.to_port}"
  protocol = "${var.protocol}"
  cidr_blocks = "${var.source_cidr}"

  security_group_id = "${var.sg_id}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_rule_id" {
  value = "aws_security_group_rule.sg_rule.id"
}
