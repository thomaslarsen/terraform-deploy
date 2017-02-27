output "region"
{
  value = "${var.region}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_name" {
  value = "${var.vdc_name}"
}

output "vpc_index" {
  value = "${var.vdc_index}"
}

output "igw_id" {
  value = "${module.vpc.igw_id}"
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

output "public_zone_id" {
  value = "${var.public_zone_id}"
}

output "domain" {
  value = "${module.vpc.domain}"
}

output "root_domain" {
  value = "${var.root_domain}"
}

output "public_domain" {
  value = "${var.public_domain_prefix}.${var.root_domain}"
}

output "name_servers" {
  value = "${module.vpc.name_servers}"
}

output "vpc_key_name" {
  value = "${var.vdc_name}-key"
}

output "secrets_bucket_id" {
  value = "${module.vpc.secrets_bucket_id}"
}
