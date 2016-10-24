variable "subnets" {
  type = "list"
  default = [ "dmz", "boundary", "public", "data", "private" ]
}

# Subnets
variable "subnet_map" {
  default = "${map(
    "dmz", 0,
    "boundary", 1,
    "public", 2,
    "data", 4,
    "private", 6
    )
  }"
}

variable "appzone_id" {
  default = "0"
}

variable "vpc_name" {
  default = "dc0"
}

variable "appzone_name" {
  default = "mtzo"
}

variable "appzone_3rd" {
  type = "list"
  default = [0,32,16,48,8,24,40,56,4,12,20,28,36,44,52,60]
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

resource "aws_subnet" 

module "subnet" {
  source = "../../modules/subnet"

  name = "dmz"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "0"
  region = "${data.terraform_remote_state.vpc.region}"
  az_a = "a"
  az_b = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}

module "boundary_subnet" {
  source = "../../modules/subnet"

  name = "boundary"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "1"
  region = "${data.terraform_remote_state.vpc.region}"
  az_a = "a"
  az_b = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}

module "public_subnet" {
  source = "../../modules/subnet"

  name = "public"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "2"
  region = "${data.terraform_remote_state.vpc.region}"
  az_a = "a"
  az_b = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}


module "data_subnet" {
  source = "../../modules/subnet"

  name = "data"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "4"
  region = "${data.terraform_remote_state.vpc.region}"
  az_a = "a"
  az_b = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}


module "private_subnet" {
  source = "../../modules/subnet"

  name = "private"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "6"
  region = "${data.terraform_remote_state.vpc.region}"
  az_a = "a"
  az_b = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}

# NACL for this appzone
resource "aws_network_acl" "app_zone_nacl" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_ids = [
    "${module.boundary_subnet.id_az_a}",
    "${module.boundary_subnet.id_az_b}",
    "${module.data_subnet.id_az_a}",
    "${module.data_subnet.id_az_b}",
    "${module.private_subnet.id_az_a}",
    "${module.private_subnet.id_az_b}"
  ]

  tags = {
    Name = "nacl-${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-default"
  }
}

module "egress_all" {
  source = "../../modules/nacl/egress_all"

  acl_id = "${aws_network_acl.app_zone_nacl.id}"
  rule_number = 2000
}

module "ingress_appzone" {
  source = "../../modules/nacl"

  acl_id = "${aws_network_acl.app_zone_nacl.id}"
  rule_number = "100"
  cidr = "10.${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}.${element(var.appzone_3rd, var.appzone_id)}.0/22"
}
