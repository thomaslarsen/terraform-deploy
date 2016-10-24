variable "sg_id" {

}

variable "type" {
  description = "Ingress or egress"
}

variable "protocol" {
  default = "all"
}

variable "cidr" {
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
    cidr_blocks = "${var.cidr}"

    security_group_id = "${var.sg_id}"
}

output "sg_rule_id" {
  value = "aws_security_group_rule.sg_rule.id"
}
