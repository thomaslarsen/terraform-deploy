variable "ami_id" {
  default = "ami-8b8c57f8"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "service" {
  default = "ldap"
}

variable "hostname" {
  default = "ldap"
}

variable "saltmaster" {
  default = "salt"
}

variable "vpc_name" {
}

variable "appzone_name" {
}

variable "subnet_list" {
  type = "list"
}

variable "az" {
  default = "0"
}

variable "zone_sg_id" {

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

module "instance" {
  source        = "../../modules/instance/thin"

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
