variable "ami_id" {
  default = "ami-8b8c57f8"
}

variable "service" {
  default = "saltmaster"
}

variable "hostname" {
  default = "salt"
}

variable "key" {
  default = "TL"
}

variable "vpc_name" {
  default = "dc0"
}

variable "appzone_name" {
  default = "mtzo"
}

variable "subnet" {
  default = "dmz"
}

variable "az" {
  default = "a"
}

variable "kickstart_url" {

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
  template = "${file("${path.module}/../../templates/${var.service}.cl")}"

  vars = {
    hostname = "${var.hostname}"
    fqdn = "${var.hostname}.${var.appzone_name}.${data.terraform_remote_state.vpc.domain}"
    kickstart_url = "${var.kickstart_url}"
    git_key = "${file("${path.module}/../../vdcs/${var.vpc_name}/secrets/${var.vpc_name}_rsa")}"
  }
}

resource "aws_instance" "instance" {
  ami = "${var.ami_id}"
  instance_type = "t2.micro"
  subnet_id = "${data.terraform_remote_state.zone.subnet_dmz_az_a_id}"
  key_name = "${data.terraform_remote_state.vpc.vpc_key_name}"
  vpc_security_group_ids = [
    "${concat(
      list(
        "${module.service_sg.sg_id}"
      ),
      "${data.terraform_remote_state.zone.sg_list}"
    )}"]

  tags = {
    Name = "${var.hostname}-${var.appzone_name}"
    Hostname = "${var.hostname}"
    FQDN = "${var.hostname}.${var.appzone_name}.${data.terraform_remote_state.vpc.domain}"
    Service = "${var.service}"
  }

  user_data = "${data.template_file.init.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------
# Create DNS record
# --------------------------------
module "service_dns" {
  source = "../../modules/route53/record"

  zone_id = "${data.terraform_remote_state.vpc.zone_id}"
  ip = "${aws_instance.instance.private_ip}"
  name = "${var.hostname}.${var.appzone_name}.${data.terraform_remote_state.vpc.domain}"
}

# --------------------------------
# Create Security Groups
# --------------------------------
module "service_sg" {
  source = "../../modules/sg"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  name = "sg-${var.service}"
}

output "instance_id" {
   value = "${aws_instance.instance.id}"
}

output "sg_id" {
  value = "${module.service_sg.sg_id}"
}
