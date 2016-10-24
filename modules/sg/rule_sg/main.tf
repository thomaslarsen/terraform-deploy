variable "sg_id" {

}

variable "type" {
  description = "Ingress or egress"
  default = "ingress"
}

variable "protocol" {
  default = "all"
}

variable "source_sg_id" {

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
    source_security_group_id = "${var.source_sg_id}"

    security_group_id = "${var.sg_id}"
}

output "sg_rule_id" {
  value = "aws_security_group_rule.sg_rule.id"
}
