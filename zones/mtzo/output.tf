
output "appzone_name" {
  value = "${var.appzone_name}"
}

output "zone_sg_id" {
  value = "${module.zone_sg.sg_id}"
}

output "sg_list" {
  value = [
    "${data.terraform_remote_state.vpc.vpc_sg_id}",
    "${module.zone_sg.sg_id}"
  ]
}

output "internal_route_table_id" {
  value = "${aws_route_table.internal.id}"
}

output "boundary_route_table_id" {
  value = "${aws_route_table.boundary.id}"
}

output "nat_gateway_id" {
  value = "${aws_nat_gateway.gw.id}"
}

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
