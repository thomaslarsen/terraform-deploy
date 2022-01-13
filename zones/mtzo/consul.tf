variable "consul_instance_type" { }

variable "consul_hostname" {
  default = "consul"
}

variable "consul_service" {
  default = "consul-server"
}

variable "consul_port" {
  default = 8500
}


output "consul_private_ip" {
  value = "${module.consul_instance.private_ip}"
}

output "consul_instance_id" {
   value = "${module.consul_instance.instance_id}"
}

output "consul_sg_id" {
  value = "${module.consul_instance.sg_id}"
}

output "consul_fqdn" {
  value = "${module.consul_instance.fqdn}"
}

# --------------------------
# Consul Server box
# --------------------------

module "consul_instance" {
  source        = "../../modules/instance/thin"

  ami_id        = "${var.thin_ami_id}"
  instance_type = "${var.consul_instance_type}"

  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  vdc_name      = "${var.vdc_name}"
  key_name      = "${data.terraform_remote_state.vpc.vpc_key_name}"
  domain        = "${data.terraform_remote_state.vpc.domain}"
  zone_id       = "${data.terraform_remote_state.vpc.zone_id}"

  subnet_list   = "${module.public_subnet.id}"
  az_index      = "0"
  sg_list       = [ "${data.terraform_remote_state.vpc.vpc_sg_id}", "${module.zone_sg.sg_id}" ]

  service       = "${var.consul_service}"
  role          = "${var.consul_service}"
  hostname      = "${var.consul_hostname}"
  appzone_name  = "${var.appzone_name}"
  class         = "${var.class}"

  saltmaster    = "${module.saltmaster_instance.fqdn}"
}

# Add ingress rules from all hosts in the VPC
module "consul_ingress" {
  source      = "../../modules/sg/rule_sg"

  sg_id         = "${module.consul_instance.sg_id}"
  protocol      = "TCP"
  from_port     = "${var.consul_port}"
  to_port       = "${var.consul_port}"
  source_sg_id  = "${data.terraform_remote_state.vpc.vpc_sg_id}"
}
