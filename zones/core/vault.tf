
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

variable "vault_version" {
  default = "latest"
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

# --------------------------
# vault box
# --------------------------

data "template_file" "vault_init" {
  template = "${file("${path.module}/../../templates/vault.cl")}"

  vars = {
    hostname        = "${var.vault_hostname}"
    fqdn            = "${var.vault_hostname}.${var.appzone_name}.${data.terraform_remote_state.vpc.domain}"
    autosign        = "*.${data.terraform_remote_state.vpc.domain}"
    service         = "${var.vault_service}"
    role            = "${var.vault_service}"
    zone            = "${var.appzone_name}"
    domain          = "${data.terraform_remote_state.vpc.domain}"
    vdc             = "${var.vdc_name}"
    class           = "${var.class}"

    vault_version   = "${var.vault_version}"
  }
}

module "vault_instance" {
  source        = "../../modules/instance"

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
  userdata      = "${data.template_file.vault_init.rendered}"
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
