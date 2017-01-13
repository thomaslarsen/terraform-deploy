variable "ami_id" {
  default = "ami-8b8c57f8"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "service" {
  default = "jump"
}

variable "hostname" {
  default = "jump"
}

variable "vpc_name" {
}

variable "appzone_name" {
  default = "mtzo"
}

variable "az" {
  default = "0"
}

variable "zone_sg_id" {

}

variable "subnet_list" {
  type = "list"
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config {
    path = "${path.module}/../../vdcs/${var.vpc_name}/terraform.tfstate"
  }
}

provider "aws" {
  region = "${data.terraform_remote_state.vpc.region}"
}

data "template_file" "init" {
  template = "${file("${path.module}/../../templates/init.cl")}"

  vars = {
    hostname = "${var.hostname}"
    fqdn = "${var.hostname}.${var.appzone_name}.${data.terraform_remote_state.vpc.domain}"
  }
}

module "instance" {
  source        = "../../modules/instance"

  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  key_name      = "${data.terraform_remote_state.vpc.vpc_key_name}"
  domain        = "${data.terraform_remote_state.vpc.domain}"
  zone_id       = "${data.terraform_remote_state.vpc.zone_id}"

  subnet_list   = "${var.subnet_list}"
  az_index      = "${var.az}"
  sg_list       = [ "${data.terraform_remote_state.vpc.vpc_sg_id}", "${var.zone_sg_id}" ]

  service       = "${var.service}"
  hostname      = "${var.hostname}"
  appzone_name  = "${var.appzone_name}"
  userdata      = "${data.template_file.init.rendered}"
}

# --------------------------------
# Create public DNS record
# --------------------------------
module "service_public_dns" {
  source = "../../modules/route53/record"

  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
  ip = "${module.instance.public_ip}"
  name = "${var.hostname}.${var.vpc_name}.${data.terraform_remote_state.vpc.public_domain}"
}

module "ssh_ingress" {
  source = "../../modules/sg/rule_cidr"

  sg_id = "${module.instance.sg_id}"
  protocol = "TCP"
  from_port = "22"
  to_port = "22"
}

output "public_ip" {
  value = "${module.instance.public_ip}"
}

output "public_fqdn" {
  value = "${var.hostname}.${var.vpc_name}.${data.terraform_remote_state.vpc.root_domain}"
}

output "fqdn" {
  value = "${module.instance.fqdn}"
}

output "private_ip" {
  value = "${module.instance.private_ip}"
}

output "instance_id" {
   value = "${module.instance.instance_id}"
}

output "sg_id" {
  value = "${module.instance.sg_id}"
}
