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

module "jump_eip" {
  source = "../../modules/eip"
}

module "dmz_subnet" {
  source = "../../modules/subnet"

  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-dmz"
  slot = "0"
  az_a = "${data.terraform_remote_state.vpc.region}a"
  az_b = "${data.terraform_remote_state.vpc.region}b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}

module "boundary_subnet" {
  source = "../../modules/subnet"

  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-boundary"
  slot = "1"
  az_a = "${data.terraform_remote_state.vpc.region}a"
  az_b = "${data.terraform_remote_state.vpc.region}b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}

module "public_subnet" {
  source = "../../modules/subnet"

  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-public"
  slot = "2"
  az_a = "${data.terraform_remote_state.vpc.region}a"
  az_b = "${data.terraform_remote_state.vpc.region}b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}


module "data_subnet" {
  source = "../../modules/subnet"

  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-data"
  slot = "4"
  az_a = "${data.terraform_remote_state.vpc.region}a"
  az_b = "${data.terraform_remote_state.vpc.region}b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}


module "private_subnet" {
  source = "../../modules/subnet"

  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-private"
  slot = "6"
  az_a = "${data.terraform_remote_state.vpc.region}a"
  az_b = "${data.terraform_remote_state.vpc.region}b"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_id)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
}

#------------------------
# NACL for this appzone
#------------------------
resource "aws_network_acl" "app_zone_nacl_internal" {
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
    Name = "nacl-${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-internal"
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "egress_all_internal" {
  source = "../../modules/nacl/egress_all"

  acl_id = "${aws_network_acl.app_zone_nacl_internal.id}"
  rule_number = 2000
}

module "ingress_appzone_internal" {
  source = "../../modules/nacl"

  acl_id = "${aws_network_acl.app_zone_nacl_internal.id}"
  rule_number = "100"
  cidr = "10.${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}.${element(var.appzone_3rd, var.appzone_id)}.0/22"
}

resource "aws_network_acl" "app_zone_nacl_external" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_ids = [
    "${module.dmz_subnet.id_az_a}",
    "${module.dmz_subnet.id_az_b}",
    "${module.public_subnet.id_az_a}",
    "${module.public_subnet.id_az_b}"
  ]

  tags = {
    Name = "nacl-${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-external"
  }
}

module "egress_all_external" {
  source = "../../modules/nacl/egress_all"

  acl_id = "${aws_network_acl.app_zone_nacl_external.id}"
  rule_number = 2000
}

module "ingress_all_external" {
  source = "../../modules/nacl/ingress_all"

  acl_id = "${aws_network_acl.app_zone_nacl_external.id}"
  rule_number = "100"
}

#------------------------
# Security Group for this appzone
#------------------------
module "zone_sg" {
  source = "../../modules/sg"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  name = "sg-${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}"
#  description = "Security Group for zone ${var.appzone_name}"
}

module "sg_egress_all" {
  source = "../../modules/sg/rule/egress_all"

  sg_id = "${module.zone_sg.sg_id}"
}

# Add ingress rule to the VPC level Security Group, allowing the jump box to access all hosts
module "jump_sgr_ingress_vpc" {
  source = "../../modules/sg/rule_sg"

  sg_id = "${module.zone_sg.sg_id}"
  protocol = "TCP"
  from_port = 22
  to_port = 22
  source_sg_id = "${module.zone_sg.sg_id}"
}
