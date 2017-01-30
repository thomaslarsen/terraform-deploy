variable "ami_id" {
}

variable "instance_type" {
}

variable "service" {
}

variable "role" {
}

variable "hostname" {
}

variable "saltmaster" {
  default = "salt"
}

variable "vpc_id" {
}

variable "vdc_name" {
}

variable "appzone_name" {
}

variable "class" {
}

variable "subnet_list" {
  type = "list"
}

variable "az_index" {
  default = "0"
}

variable "key_name" {
}

variable "sg_list" {
  type = "list"
}

variable "domain" {
}

variable "zone_id" {
}

variable "template" {
  default = "thin.cl"
}

data "template_file" "init" {
  template = "${file("${path.module}/../../../templates/${var.template}")}"

  vars = {
    hostname      = "${var.hostname}"
    fqdn          = "${var.hostname}.${var.appzone_name}.${var.domain}"
    saltmaster    = "${var.saltmaster}"
    service       = "${var.service}"
    role          = "${var.role}"
    zone          = "${var.appzone_name}"
    domain        = "${var.domain}"
    vdc           = "${var.vdc_name}"
    class         = "${var.class}"
  }
}

module "instance" {
  source        = "../"

  ami_id        = "${var.ami_id}"
  instance_type = "${var.instance_type}"

  vpc_id        = "${var.vpc_id}"
  vdc_name      = "${var.vdc_name}"
  key_name      = "${var.key_name}"
  domain        = "${var.domain}"
  zone_id       = "${var.zone_id}"

  subnet_list   = "${var.subnet_list}"
  az_index      = "${var.az_index}"
  sg_list       = "${var.sg_list}"

  service       = "${var.service}"
  role          = "${var.role}"
  hostname      = "${var.hostname}"
  appzone_name  = "${var.appzone_name}"
  userdata      = "${data.template_file.init.rendered}"
}

output "private_ip" {
  value = "${module.instance.private_ip}"
}

output "public_ip" {
  value = "${module.instance.public_ip}"
}

output "instance_id" {
   value = "${module.instance.instance_id}"
}

output "sg_id" {
  value = "${module.instance.sg_id}"
}

output "fqdn" {
  value = "${module.instance.fqdn}"
}
