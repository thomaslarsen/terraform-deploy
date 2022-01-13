variable "saltmaster_instance_type" { }

variable "saltmaster_hostname" {
  default = "salt"
}

variable "saltmaster_service" {
  default = "saltmaster"
}

variable "saltmaster_publish_port" {
  default = 4505
}

variable "saltmaster_ret_port" {
  default = 4506
}


output "saltmaster_fqdn" {
  value = "${module.saltmaster_instance.fqdn}"
}

output "saltmaster_private_ip" {
  value = "${module.saltmaster_instance.private_ip}"
}

output "saltmaster_instance_id" {
   value = "${module.saltmaster_instance.instance_id}"
}

output "saltmaster_sg_id" {
  value = "${module.saltmaster_instance.sg_id}"
}

# --------------------------
# Salt master
# --------------------------

data "template_file" "saltmaster_init" {
  template = "${file("${path.module}/../../templates/saltmaster.cl")}"

  vars = {
    hostname        = "${var.saltmaster_hostname}"
    fqdn            = "${var.saltmaster_hostname}.${var.appzone_name}.${data.terraform_remote_state.vpc.domain}"
    autosign        = "*.${data.terraform_remote_state.vpc.domain}"
    service         = "${var.saltmaster_service}"
    role            = "${var.saltmaster_service}"
    zone            = "${var.appzone_name}"
    domain          = "${data.terraform_remote_state.vpc.domain}"
    vdc             = "${var.vdc_name}"
    class           = "${var.class}"
  }
}

module "saltmaster_instance" {
  source        = "../../modules/instance"

  ami_id        = "${var.thin_ami_id}"
  instance_type = "${var.saltmaster_instance_type}"

  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  vdc_name      = "${var.vdc_name}"
  key_name      = "${data.terraform_remote_state.vpc.vpc_key_name}"
  domain        = "${data.terraform_remote_state.vpc.domain}"
  zone_id       = "${data.terraform_remote_state.vpc.zone_id}"

  subnet_list   = "${module.private_subnet.id}"
  az_index      = "0"
  sg_list       = [ "${data.terraform_remote_state.vpc.vpc_sg_id}", "${module.zone_sg.sg_id}" ]

  service       = "${var.saltmaster_service}"
  role          = "${var.saltmaster_service}"
  hostname      = "${var.saltmaster_hostname}"
  appzone_name  = "${var.appzone_name}"
  class         = "${var.class}"
  userdata      = "${data.template_file.saltmaster_init.rendered}"
}

# Add ingress rules from all hosts in the VPC
module "saltmaster_ingress_publish_port" {
  source = "../../modules/sg/rule_sg"

  sg_id         = "${module.saltmaster_instance.sg_id}"
  protocol      = "TCP"
  from_port     = "${var.saltmaster_publish_port}"
  to_port       = "${var.saltmaster_publish_port}"
  source_sg_id  = "${data.terraform_remote_state.vpc.vpc_sg_id}"
}
module "saltmaster_ingress_ret_port" {
  source = "../../modules/sg/rule_sg"

  sg_id         = "${module.saltmaster_instance.sg_id}"
  protocol      = "TCP"
  from_port     = "${var.saltmaster_ret_port}"
  to_port       = "${var.saltmaster_ret_port}"
  source_sg_id  = "${data.terraform_remote_state.vpc.vpc_sg_id}"
}
