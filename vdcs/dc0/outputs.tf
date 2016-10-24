output "region"
{
  value = "${var.region}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_name" {
  value = "${var.vpc_name}"
}

output "vpc_index" {
  value = "${var.dc_index}"
}

output "igw_id" {
  value = "${module.vpc.igw_id}"
}

output "default_nacl_id" {
  value = "${module.vpc.default_nacl_id}"
}

output "default_route_table_id" {
  value = "${module.vpc.default_route_table_id}"
}

output "vpc_sg_id" {
  value = "${module.vpc.vpc_sg_id}"
}

# VPC subnet
output "vpc_cidr_2nd_octet" {
  value = "${data.null_data_source.net.inputs.vpc_2nd_octet}"
}

output "vpc_cidr_3rd_octet" {
  value = "${data.null_data_source.net.inputs.vpc_3rd_octet}"
}

output "vpc_cidr" {
  value = "${module.vpc.vpc_cidr}"
}


output "zone_id" {
  value = "${module.vpc.zone_id}"
}

output "domain" {
  value = "${module.vpc.domain}"
}

output "name_servers" {
  value = "${module.vpc.name_servers}"
}

output "vpc_key_name" {
  value = "${var.vpc_name}-key"
}
