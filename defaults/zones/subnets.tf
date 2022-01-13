output "subnet_dmz_id" {
  value = "${module.dmz_subnet.id}"
}

output "subnet_dmz_cidr" {
  value = "${module.dmz_subnet.cidr}"
}


output "subnet_boundary_id" {
  value = "${module.boundary_subnet.id}"
}

output "subnet_boundary_cidr" {
  value = "${module.boundary_subnet.cidr}"
}


output "subnet_public_id" {
  value = "${module.public_subnet.id}"
}

output "subnet_public_cidr" {
  value = "${module.public_subnet.cidr}"
}


output "subnet_data_id" {
  value = "${module.data_subnet.id}"
}

output "subnet_data_cidr" {
  value = "${module.data_subnet.cidr}"
}


output "subnet_private_id" {
  value = "${module.private_subnet.id}"
}

output "subnet_private_cidr" {
  value = "${module.private_subnet.cidr}"
}


module "dmz_subnet" {
  source = "../../modules/subnet"

  map_public_ip = true

  region = "${data.terraform_remote_state.vpc.region}"
  name = "${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-dmz"
  slot = "0"

  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  octet2 = "${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}"
  octet3 = "${element(var.appzone_3rd, var.appzone_index)}"

  route_table_id = "${data.terraform_remote_state.vpc.default_route_table_id}"
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
