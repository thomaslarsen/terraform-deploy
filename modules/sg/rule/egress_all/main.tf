variable "sg_id" {

}

module "sg_rule_egress_all" {
  source = "../cidr"

  sg_id = "${var.sg_id}"
  type = "egress"
}

output "sg_rule_id" {
  value = "module.sg_rule_egress_all.sg_rule_id"
}
