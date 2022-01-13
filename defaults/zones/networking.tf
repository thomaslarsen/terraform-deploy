variable "nat_az" {
  default = 0
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


#------------------------
# NAT gateway for this appzone
#------------------------

# Create a NAT gateway in the DMZ subnet
module "nat_ip" {
  source = "../../modules/eip"
}

resource "aws_nat_gateway" "gw" {
  allocation_id   = "${module.nat_ip.eip_id}"
  subnet_id       = "${element(module.dmz_subnet.id, var.nat_az)}"
}

#------------------------
# Route Tables for this appzone
#------------------------

# Create a routing table for the internal subnets
resource "aws_route_table" "internal" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  tags {
    Name = "rt-${var.appzone_name}-internal"
  }
}

# Add default route through NAT gateway to internal route table
resource "aws_route" "proxy_route" {
  route_table_id          = "${aws_route_table.internal.id}"
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = "${aws_nat_gateway.gw.id}"
}



# Create a routing table for the boundary subnet
resource "aws_route_table" "boundary" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  tags {
    Name = "rt-${var.appzone_name}-boundary"
  }
}


#------------------------
# Network ACLs for this appzone
#------------------------
resource "aws_network_acl" "app_zone_nacl_internal" {
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_ids  = ["${concat(
    "${module.boundary_subnet.id}",
    "${module.data_subnet.id}",
    "${module.private_subnet.id}"
    )}"]

  tags = {
    Name = "nacl-${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-internal"
  }
}

# Allow ingress from all nodes in this appzone (using the CIDR)
module "ingress_appzone_internal" {
  source      = "../../modules/nacl"

  acl_id      = "${aws_network_acl.app_zone_nacl_internal.id}"
  rule_number = 100
  cidr        = "10.${data.terraform_remote_state.vpc.vpc_cidr_2nd_octet}.${element(var.appzone_3rd, var.appzone_index)}.0/22"
}

# Allow ingress from ephemeral ports from all sources
module "ingress_ephemeral_internal" {
  source      = "../../modules/nacl/ephemeral"

  acl_id      = "${aws_network_acl.app_zone_nacl_internal.id}"
  rule_number = 110
}

module "egress_all_internal" {
  source      = "../../modules/nacl/egress_all"

  acl_id      = "${aws_network_acl.app_zone_nacl_internal.id}"
  rule_number = 2000
}



resource "aws_network_acl" "app_zone_nacl_external" {
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_ids  = ["${concat(
    "${module.dmz_subnet.id}",
    "${module.public_subnet.id}"
    )}"]

  tags = {
    Name = "nacl-${data.terraform_remote_state.vpc.vpc_name}-${var.appzone_name}-external"
  }
}

module "ingress_all_external" {
  source      = "../../modules/nacl/ingress_all"

  acl_id      = "${aws_network_acl.app_zone_nacl_external.id}"
  rule_number = 100
}

module "egress_all_external" {
  source      = "../../modules/nacl/egress_all"

  acl_id      = "${aws_network_acl.app_zone_nacl_external.id}"
  rule_number = 2000
}
