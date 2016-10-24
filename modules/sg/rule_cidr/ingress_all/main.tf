variable "sg_id" {

}

module "sg_rule_ingress_all" {
  source = "../"

  sg_id = "${var.sg_id}"
}

output "sg_rule_id" {
  value = "module.sg_rule_ingress_all.sg_rule_id"
}
