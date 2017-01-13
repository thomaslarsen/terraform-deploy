variable "ami_id" {
  default = "ami-8b8c57f8"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "service" {
  default = "saltmaster"
}

variable "hostname" {
  default = "salt"
}

variable "vpc_name" {
}

variable "appzone_name" {
  default = "mtzo"
}

variable "subnet_list" {
  type = "list"
}

variable "az" {
  default = "0"
}

variable "zone_sg_id" {

}

variable "kickstart_url" {

}

variable "kickstart_branch" {
  default = "master"
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
  template = "${file("${path.module}/../../templates/${var.service}.cl")}"

  vars = {
    hostname = "${var.hostname}"
    fqdn = "${var.hostname}.${var.appzone_name}.${data.terraform_remote_state.vpc.domain}"
    kickstart_url = "${var.kickstart_url}"
    git_key = "${file("${path.module}/../../vdcs/${var.vpc_name}/secrets/${var.vpc_name}_rsa")}"
    branch = "${var.kickstart_branch}"
    autosign = "*.${data.terraform_remote_state.vpc.domain}"
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

# Add ingress rules from all hosts in the VPC
module "saltmaster_ingress" {
  source = "../../modules/sg/rule_sg"

  sg_id = "${module.instance.sg_id}"
  protocol = "TCP"
  from_port = "4505"
  to_port = "4506"
  source_sg_id = "${data.terraform_remote_state.vpc.vpc_sg_id}"
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
