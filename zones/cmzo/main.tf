variable "appzone_id" {
  default = "1"
}

variable "appzone_name" {
  default = "cozo"
}

variable "appzone_3rd" {
  type = "list"
  default = [0,32,16,48,8,24,40,56,4,12,20,28,36,44,52,60]
}

data "terraform_remote_state" "vpc" {
    backend = "local"
    config {
        path = "${path.module}/../dc0/terraform.tfstate"
    }
}


provider "aws" {
  region = "${data.terraform_remote_state.vpc.region}"
}


module "dmz_subnet" {
  source = "../modules/subnet"

  name = "dmz"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "0"
  region = "${data.terraform_remote_state.vpc.region}"
  az_1 = "a"
  az_2 = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}


module "boundary_subnet" {
  source = "../modules/subnet"

  name = "boundary"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "1"
  region = "${data.terraform_remote_state.vpc.region}"
  az_1 = "a"
  az_2 = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}

module "public_subnet" {
  source = "../modules/subnet"

  name = "public"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "2"
  region = "${data.terraform_remote_state.vpc.region}"
  az_1 = "a"
  az_2 = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}


module "data_subnet" {
  source = "../modules/subnet"

  name = "data"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "4"
  region = "${data.terraform_remote_state.vpc.region}"
  az_1 = "a"
  az_2 = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}


module "private_subnet" {
  source = "../modules/subnet"

  name = "private"
  vpc_name = "${data.terraform_remote_state.vpc.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_slot = "6"
  region = "${data.terraform_remote_state.vpc.region}"
  az_1 = "a"
  az_2 = "b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_2nd_octet = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  appzone_3rd_octet = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}

# NACL for this appzone
resource "aws_network_acl" "app_zone_nacl" {
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
    subnet_ids = [
      "${module.dmz_subnet.cidr_az_1}",
      "${module.dmz_subnet.cidr_az_2}",
      "${module.boundary_subnet.cidr_az_1}",
      "${module.boundary_subnet.cidr_az_2}",
      "${module.public_subnet.cidr_az_1}",
      "${module.public_subnet.cidr_az_2}",
      "${module.data_subnet.cidr_az_1}",
      "${module.data_subnet.cidr_az_2}",
      "${module.private_subnet.cidr_az_1}",
      "${module.private_subnet.cidr_az_2}"
    ]
}

module "egress_all" {
  source = "../modules/nacl/egress_all"

  acl_id = "${aws_network_acl.app_zone_nacl.id}"
  rule_number = 2000
}


module "ingress_appzone" {
  source = "../modules/nacl"

  acl_id = "${aws_network_acl.app_zone_nacl.id}"
  rule_number = "100"
  cidr = "10.${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}.${element(var.appzone_3rd, var.appzone_id)}.0/22"
}
