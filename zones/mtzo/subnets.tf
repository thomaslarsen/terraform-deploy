
module "dmz_subnet" {
  source = "../../modules/subnet"

  region = "${data.terraform_remote_state.vpc.region}"
  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-dmz"
  slot = "0"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_index)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
  map_public_ip = true
}

module "boundary_subnet" {
  source = "../../modules/subnet"

  region = "${data.terraform_remote_state.vpc.region}"
  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-boundary"
  slot = "1"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_index)}"

  route_table_id = "${aws_route_table.boundary.id}"
}

module "public_subnet" {
  source = "../../modules/subnet"

  region = "${data.terraform_remote_state.vpc.region}"
  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-public"
  slot = "2"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_index)}"

  route_table_id = "${aws_route_table.internal.id}"
}


module "data_subnet" {
  source = "../../modules/subnet"

  region = "${data.terraform_remote_state.vpc.region}"
  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-data"
  slot = "4"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_index)}"

  route_table_id = "${aws_route_table.internal.id}"
}


module "private_subnet" {
  source = "../../modules/subnet"

  region = "${data.terraform_remote_state.vpc.region}"
  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-private"
  slot = "6"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_index)}"

  route_table_id = "${aws_route_table.internal.id}"
}
