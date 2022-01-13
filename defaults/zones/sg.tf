
output "zone_sg_id" {
  value = "${module.zone_sg.sg_id}"
}

output "sg_list" {
  value = [
    "${data.terraform_remote_state.vpc.vpc_sg_id}",
    "${module.zone_sg.sg_id}"
  ]
}

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
