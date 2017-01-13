#------------------------
# Security Group for this appzone
#------------------------
module "zone_sg" {
  source        = "../../modules/sg"

  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  name          = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}"
  description   = "Security Group for app zone ${var.appzone_name} in VPC ${data.terraform_remote_state.vpc.vpc_name}"
}

module "sg_egress_all" {
  source        = "../../modules/sg/rule/egress_all"

  sg_id         = "${module.zone_sg.sg_id}"
}

# Add ingress rule to the VPC level Security Group, allowing SSH access between all hosts
module "jump_sgr_ingress_vpc" {
  source        = "../../modules/sg/rule_sg"

  sg_id         = "${module.zone_sg.sg_id}"
  protocol      = "TCP"
  from_port     = "${var.jump_ssh_port}"
  to_port       = "${var.jump_ssh_port}"
  source_sg_id  = "${module.zone_sg.sg_id}"
}
