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

variable "subnet" {
  default = "dmz"
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

module "jump_instance" {
  source        = "../../modules/instance"

  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  key_name      = "${data.terraform_remote_state.vpc.vpc_key_name}"
  domain        = "${data.terraform_remote_state.vpc.domain}"
  zone_id       = "${data.terraform_remote_state.vpc.zone_id}"

  subnet_id     = "${data.terraform_remote_state.zone.subnet_dmz_az_a_id}"
  sg_list       = "${data.terraform_remote_state.zone.sg_list}"

  service       = "${var.service}"
  hostname      = "${var.hostname}"
  appzone_name  = "${var.appzone_name}"
  userdata      = "${data.template_file.init.rendered}"
}

# --------------------------------
# Associate the Jump Box EIP defined at the VPC level
# --------------------------------
resource "aws_eip_association" "eip_assoc" {
  instance_id = "${module.jump_instance.instance_id}"
  allocation_id = "${data.terraform_remote_state.zone.jump_eip_id}"

  lifecycle {
    create_before_destroy = true
  }
}

module "ssh_ingress" {
  source = "../../modules/sg/rule_cidr"

  sg_id = "${module.jump_instance.sg_id}"
  protocol = "TCP"
  from_port = "22"
  to_port = "22"
}


module "ssh_ingress_from_jump" {
  source = "../../modules/sg/rule_sg"

  sg_id = "${data.terraform_remote_state.zone.zone_sg_id}"
  source_sg_id = "${module.jump_instance.sg_id}"
  protocol = "TCP"
  from_port = "22"
  to_port = "22"
}

output "public_ip" {
  value = "${data.terraform_remote_state.zone.jump_ip}"
}

output "private_ip" {
  value = "${module.jump_instance.private_ip}"
}

output "instance_id" {
   value = "${module.jump_instance.instance_id}"
}

output "sg_id" {
  value = "${module.jump_instance.sg_id}"
}
