variable "acl_id" {

}

variable "rule_number" {

}

module "ephemeral" {
  source = "../"

  acl_id      = "${var.acl_id}"
  rule_number = "${var.rule_number}"
  protocol    = "tcp"
  from_port   = "1024"
}

output "nacl_rule_id" {
  value = "${module.ephemeral.nacl_rule_id}"
}
