
variable "test_ami"     { default = "ami-8b8c57f8" }

variable "vpc_name" {
  default = "dc0"
}

variable "appzone_name" {
  default = "mtzo"
}

variable "kickstart_url" {

}

variable "kickstart_branch" {
  default = "master"
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config {
    path = "${path.module}/../../../vdcs/${var.vpc_name}/terraform.tfstate"
  }
}

data "terraform_remote_state" "zone" {
  backend = "local"
  config {
    path = "${path.module}/../../../zones/${var.appzone_name}/terraform.tfstate"
  }
}

provider "aws" {
  region = "${data.terraform_remote_state.vpc.region}"
}

#--------------------------------------------------------------
# Services
#--------------------------------------------------------------

module "saltmaster" {
  source = "../../../services/saltmaster"

  ami_id = "${var.test_ami}"
  vpc_name = "${var.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_list = "${data.terraform_remote_state.zone.subnet_private_id}"

  kickstart_url = "${var.kickstart_url}"
  kickstart_branch = "${var.kickstart_branch}"
}

module "ldap" {
  source = "../../../services/ldap"

  ami_id = "${var.test_ami}"
  vpc_name = "${var.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_list = "${data.terraform_remote_state.zone.subnet_private_id}"

  saltmaster = "${module.saltmaster.fqdn}"
}
