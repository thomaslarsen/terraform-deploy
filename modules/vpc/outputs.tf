# VPC
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_sg_id" {
  value = "${module.vpc_sg.sg_id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

# Internet Gateway
output "igw_id" {
  value = "${aws_internet_gateway.ig.id}"
}

output "default_route_table_id" {
  value = "${aws_route_table.default.id}"
}

output "default_nacl_id" {
  value = "${aws_default_network_acl.default.id}"
}

output "zone_id" {
  value = "${module.vpc_dns_zone.zone_id}"
}

output "domain" {
  value = "${var.name}.${var.root_domain}"
}

output "name_servers" {
  value = "${module.vpc_dns_zone.name_servers}"
}
