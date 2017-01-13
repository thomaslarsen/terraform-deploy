variable "acl_id" {

}

variable "rule_number" {

}

variable "egress" {
  default = "false"
}

variable "protocol" {
  default = "all"
}

variable "action" {
  default = "allow"
}

variable "cidr" {
  default = "0.0.0.0/0"
}

variable "from_port" {
  default = "0"
}

variable "to_port" {
  default = "65535"
}

resource "aws_network_acl_rule" "nacl_rule" {
    network_acl_id    = "${var.acl_id}"
    rule_number       = "${var.rule_number}"
    egress            = "${var.egress}"
    protocol          = "${var.protocol}"
    rule_action       = "${var.action}"
    cidr_block        = "${var.cidr}"
    from_port         = "${var.from_port}"
    to_port           = "${var.to_port}"

    lifecycle {
      create_before_destroy = true
    }
}

output "nacl_rule_id" {
  value = "${aws_network_acl_rule.nacl_rule.id}"
}
