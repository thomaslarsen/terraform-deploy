variable "ldap_instance_type" { }

variable "ldap_hostname" {
  default = "ldap"
}

variable "ldap_service" {
  default = "ldap"
}

variable "ldap_port" {
  default = 389
}


output "ldap_fqdn" {
  value = "${module.ldap_instance.fqdn}"
}

output "ldap_private_ip" {
  value = "${module.ldap_instance.private_ip}"
}

output "ldap_instance_id" {
   value = "${module.ldap_instance.instance_id}"
}

output "ldap_sg_id" {
  value = "${module.ldap_instance.sg_id}"
}

# --------------------------
# LDAP box
# --------------------------

module "ldap_instance" {
  source        = "../../modules/instance/thin"

  ami_id        = "${var.thin_ami_id}"
  instance_type = "${var.ldap_instance_type}"

  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  vdc_name      = "${var.vdc_name}"
  key_name      = "${data.terraform_remote_state.vpc.vpc_key_name}"
  domain        = "${data.terraform_remote_state.vpc.domain}"
  zone_id       = "${data.terraform_remote_state.vpc.zone_id}"

  subnet_list   = "${module.private_subnet.id}"
  az_index      = "0"
  sg_list       = [ "${data.terraform_remote_state.vpc.vpc_sg_id}", "${module.zone_sg.sg_id}" ]

  service       = "${var.ldap_service}"
  role          = "${var.ldap_service}"
  hostname      = "${var.ldap_hostname}"
  appzone_name  = "${var.appzone_name}"
  class         = "${var.class}"

  saltmaster    = "${module.saltmaster_instance.fqdn}"
}

# Add ingress rules from all hosts in the VPC
module "ldap_ingress" {
  source      = "../../modules/sg/rule_sg"

  sg_id         = "${module.ldap_instance.sg_id}"
  protocol      = "TCP"
  from_port     = "${var.ldap_port}"
  to_port       = "${var.ldap_port}"
  source_sg_id = "${data.terraform_remote_state.vpc.vpc_sg_id}"
}
