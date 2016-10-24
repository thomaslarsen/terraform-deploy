variable "ami_id" {
  default = "ami-8b8c57f8"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "service" {
  default = "blank"
}

variable "hostname" {
  default = "blank"
}


variable "vpc_name" {
}

variable "appzone_name" {
}

variable "subnet_id" {
}

data "terraform_remote_state" "vpc" {
    backend = "local"
    config {
        path = "${path.module}/../../vdcs/${var.vpc_name}/terraform.tfstate"
    }
}

data "terraform_remote_state" "zone" {
    backend = "local"
    config {
        path = "${path.module}/../../zones/${var.appzone_name}/terraform.tfstate"
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

  subnet_id     = "${var.subnet_id}"
  sg_list       = "${data.terraform_remote_state.zone.sg_list}"

  service       = "${var.service}"
  hostname      = "${var.hostname}"
  appzone_name  = "${var.appzone_name}"
  userdata      = "${data.template_file.init.rendered}"
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
