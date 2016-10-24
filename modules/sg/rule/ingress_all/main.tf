variable "sg_id" {

}

module "sg_rule_ingress_all" {
  source = "../cidr"

  sg_id = "${var.sg_id}"
  type = "ingress"
}

output "sg_rule_id" {
  value = "module.sg_rule_ingress_all.sg_rule_id"
}
