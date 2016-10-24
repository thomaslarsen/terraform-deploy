output "jump_eip_id" {
  value = "${module.jump_eip.eip_id}"
}

output "jump_ip" {
  value = "${module.jump_eip.public_ip}"
}

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

output "subnet_dmz_az_a_id" {
  value = "${module.dmz_subnet.id_az_a}"
}

output "subnet_dmz_az_b_id" {
  value = "${module.dmz_subnet.id_az_b}"
}

output "subnet_dmz_cidr_az_a" {
  value = "${module.dmz_subnet.cidr_az_a}"
}

output "subnet_dmz_cidr_az_b" {
  value = "${module.dmz_subnet.cidr_az_b}"
}


output "subnet_boundary_az_a_id" {
  value = "${module.boundary_subnet.id_az_a}"
}

output "subnet_boundary_az_b_id" {
  value = "${module.public_subnet.id_az_b}"
}

output "subnet_boundary_cidr_az_a" {
  value = "${module.boundary_subnet.cidr_az_a}"
}

output "subnet_boundary_cidr_az_b" {
  value = "${module.boundary_subnet.cidr_az_b}"
}


output "subnet_public_az_a_id" {
  value = "${module.public_subnet.id_az_a}"
}

output "subnet_public_az_b_id" {
  value = "${module.public_subnet.id_az_b}"
}

output "subnet_public_cidr_az_a" {
  value = "${module.public_subnet.cidr_az_a}"
}

output "subnet_public_cidr_az_b" {
  value = "${module.public_subnet.cidr_az_b}"
}


output "subnet_data_az_a_id" {
  value = "${module.data_subnet.id_az_a}"
}

output "subnet_data_az_b_id" {
  value = "${module.data_subnet.id_az_b}"
}

output "subnet_data_cidr_az_a" {
  value = "${module.data_subnet.cidr_az_b}"
}

output "subnet_data_cidr_az_b" {
  value = "${module.data_subnet.cidr_az_b}"
}


output "subnet_private_az_a_id" {
  value = "${module.private_subnet.id_az_a}"
}

output "subnet_private_az_b_id" {
  value = "${module.private_subnet.id_az_b}"
}

output "subnet_private_cidr_az_a" {
  value = "${module.private_subnet.cidr_az_a}"
}

output "subnet_private_cidr_az_b" {
  value = "${module.private_subnet.cidr_az_b}"
}
