variable "acl_id" {

}

variable "rule_number" {

}

module "egress_all" {
  source = "../"

  acl_id      = "${var.acl_id}"
  rule_number = "${var.rule_number}"
  egress      = true
}

output "nacl_rule_id" {
  value = "${module.egress_all.nacl_rule_id}"
}
