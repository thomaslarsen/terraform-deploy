
variable "saltmaster_kickstart_url" { }

variable "saltmaster_kickstart_branch" { }

variable "thin_ami_id" { }

variable "jump_instance_type" {
}
variable "ldap_instance_type" {
}
variable "saltmaster_instance_type" {
}
variable "consul_instance_type" {
}

variable "jump_hostname" {
  default = "jump"
}

variable "jump_service" {
  default = "jump"
}

variable "saltmaster_hostname" {
  default = "salt"
}

variable "saltmaster_service" {
  default = "saltmaster"
}

variable "ldap_hostname" {
  default = "ldap"
}

variable "ldap_service" {
  default = "ldap"
}

variable "consul_hostname" {
  default = "consul"
}

variable "consul_service" {
  default = "consul-server"
}

variable "jump_ssh_port" {
  default = 22
}

variable "saltmaster_publish_port" {
  default = 4505
}

variable "saltmaster_ret_port" {
  default = 4506
}
variable "ldap_port" {
  default = 389
}

variable "consul_port" {
  default = 8500
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
  source = "../../modules/route53/record"

  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
  ip = "${module.jump_instance.public_ip}"
  name = "${var.jump_hostname}.${var.vdc_name}.${data.terraform_remote_state.vpc.public_domain}"
}

module "ssh_ingress" {
  source = "../../modules/sg/rule_cidr"

  sg_id = "${module.jump_instance.sg_id}"
  protocol = "TCP"
  from_port = "${var.jump_ssh_port}"
  to_port = "${var.jump_ssh_port}"
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
# Salt master
# --------------------------

data "template_file" "saltmaster_init" {
  template = "${file("${path.module}/../../templates/saltmaster.cl")}"

  vars = {
    hostname        = "${var.saltmaster_hostname}"
    fqdn            = "${var.saltmaster_hostname}.${var.appzone_name}.${data.terraform_remote_state.vpc.domain}"
    kickstart_url   = "${var.saltmaster_kickstart_url}"
    branch          = "${var.saltmaster_kickstart_branch}"
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

  sg_id = "${module.saltmaster_instance.sg_id}"
  protocol = "TCP"
  from_port = "${var.saltmaster_publish_port}"
  to_port = "${var.saltmaster_publish_port}"
  source_sg_id = "${data.terraform_remote_state.vpc.vpc_sg_id}"
}
module "saltmaster_ingress_ret_port" {
  source = "../../modules/sg/rule_sg"

  sg_id = "${module.saltmaster_instance.sg_id}"
  protocol = "TCP"
  from_port = "${var.saltmaster_ret_port}"
  to_port = "${var.saltmaster_ret_port}"
  source_sg_id = "${data.terraform_remote_state.vpc.vpc_sg_id}"
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
  source = "../../modules/sg/rule_sg"

  sg_id = "${module.ldap_instance.sg_id}"
  protocol = "TCP"
  from_port = "${var.ldap_port}"
  to_port = "${var.ldap_port}"
  source_sg_id = "${data.terraform_remote_state.vpc.vpc_sg_id}"
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
  source = "../../modules/sg/rule_sg"

  sg_id = "${module.consul_instance.sg_id}"
  protocol = "TCP"
  from_port = "${var.consul_port}"
  to_port = "${var.consul_port}"
  source_sg_id = "${data.terraform_remote_state.vpc.vpc_sg_id}"
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
# vault box
# --------------------------

variable "vault_instance_type" { }

variable "vault_hostname" {
  default = "vault"
}

variable "vault_service" {
  default = "vault-server"
}

variable "vault_port" {
  default = 8200
}

module "vault_instance" {
  source        = "../../modules/instance/thin"

  ami_id        = "${var.thin_ami_id}"
  instance_type = "${var.vault_instance_type}"

  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  vdc_name      = "${var.vdc_name}"
  key_name      = "${data.terraform_remote_state.vpc.vpc_key_name}"
  domain        = "${data.terraform_remote_state.vpc.domain}"
  zone_id       = "${data.terraform_remote_state.vpc.zone_id}"

  subnet_list   = "${module.public_subnet.id}"
  az_index      = "0"
  sg_list       = [ "${data.terraform_remote_state.vpc.vpc_sg_id}", "${module.zone_sg.sg_id}" ]

  service       = "${var.vault_service}"
  role          = "${var.vault_service}"
  hostname      = "${var.vault_hostname}"
  appzone_name  = "${var.appzone_name}"
  class         = "${var.class}"

  saltmaster    = "${module.saltmaster_instance.fqdn}"
}

# Add ingress rules from all hosts in the VPC
module "vault_ingress" {
  source = "../../modules/sg/rule_sg"

  sg_id = "${module.vault_instance.sg_id}"
  protocol = "TCP"
  from_port = "${var.vault_port}"
  to_port = "${var.vault_port}"
  source_sg_id = "${data.terraform_remote_state.vpc.vpc_sg_id}"
}

output "vault_private_ip" {
  value = "${module.vault_instance.private_ip}"
}

output "vault_instance_id" {
   value = "${module.vault_instance.instance_id}"
}

output "vault_sg_id" {
  value = "${module.vault_instance.sg_id}"
}

output "vault_fqdn" {
  value = "${module.vault_instance.fqdn}"
}
