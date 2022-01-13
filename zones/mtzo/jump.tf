variable "jump_instance_type" { }

variable "jump_hostname" {
  default = "jump"
}

variable "jump_service" {
  default = "jump"
}

variable "jump_ssh_port" {
  default = 22
}


output "jump_public_ip" {
  value = "${module.jump_instance.public_ip}"
}

output "jump_public_fqdn" {
  value = "${var.jump_hostname}.${var.vdc_name}.${data.terraform_remote_state.vpc.public_domain}"
}

output "jump_private_ip" {
  value = "${module.jump_instance.private_ip}"
}

output "jump_instance_id" {
   value = "${module.jump_instance.instance_id}"
}

output "jump_sg_id" {
  value = "${module.jump_instance.sg_id}"
}

output "jump_fqdn" {
  value = "${module.jump_instance.fqdn}"
}

# --------------------------
# Jump box
# --------------------------

module "jump_instance" {
  source        = "../../modules/instance/thin"

  ami_id        = "${var.thin_ami_id}"
  instance_type = "${var.jump_instance_type}"

  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  vdc_name      = "${var.vdc_name}"
  key_name      = "${data.terraform_remote_state.vpc.vpc_key_name}"
  domain        = "${data.terraform_remote_state.vpc.domain}"
  zone_id       = "${data.terraform_remote_state.vpc.zone_id}"

  subnet_list   = "${module.dmz_subnet.id}"
  az_index      = "0"
  sg_list       = [ "${data.terraform_remote_state.vpc.vpc_sg_id}", "${module.zone_sg.sg_id}" ]

  service       = "${var.jump_service}"
  role          = "${var.jump_service}"
  hostname      = "${var.jump_hostname}"
  appzone_name  = "${var.appzone_name}"
  class         = "${var.class}"

  #template      = "init.cl"
  saltmaster    = "${module.saltmaster_instance.fqdn}"
}

# --------------------------------
# Create public DNS record
# --------------------------------
module "service_public_dns" {
  source    = "../../modules/route53/record"

  zone_id   = "${data.terraform_remote_state.vpc.public_zone_id}"
  ip        = "${module.jump_instance.public_ip}"
  name      = "${var.jump_hostname}.${var.vdc_name}.${data.terraform_remote_state.vpc.public_domain}"
}

module "ssh_ingress" {
  source      = "../../modules/sg/rule_cidr"

  sg_id       = "${module.jump_instance.sg_id}"
  protocol    = "TCP"
  from_port   = "${var.jump_ssh_port}"
  to_port     = "${var.jump_ssh_port}"
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
