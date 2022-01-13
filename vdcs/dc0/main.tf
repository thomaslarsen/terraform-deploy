// data "null_data_source" "net" {
// # Calculate the VPC subnet octets
//   inputs = {
//     vpc_2nd_octet = "${var.vdc_index * 16 + 16}"
//
//     vpc_3rd_octet = "${(64 * (var.vdc_index / 16)) % 256}"
//   }
// }
//
// module "vpc" {
//   source = "../../modules/vpc"
//
//   name = "${var.vdc_name}"
//   cidr = "10.${data.null_data_source.net.inputs.vpc_2nd_octet}.${data.null_data_source.net.inputs.vpc_3rd_octet}.0/${var.vdc_subnet_size}"
//   root_domain = "${var.root_domain}"
// }

locals {
  vpc_2nd_octet = "${var.vdc_index * 16 + 16}"
  vpc_3rd_octet = "${(64 * (var.vdc_index / 16)) % 256}"
  cidr = "10.${local.vpc_2nd_octet}.${local.vpc_3rd_octet}.0/${var.vdc_subnet_size}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${local.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vdc_name}"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "ig-${var.vdc_name}"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"
  }

  tags {
    Name = "rt-${var.vdc_name}-default"
  }

  lifecycle {
    create_before_destroy = true
  }
}

// module "vpc_sg" {
//   source = "../sg"
//
//   vpc_id = "${aws_vpc.vpc.id}"
//   name = "${var.vdc_name}"
//   description = "Security Group for VPC ${var.vdc_name}"
// }

resource "aws_security_group" "sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  description = "Security Group for VPC ${var.vdc_name}"
  name = "${var.vdc_name}"

  tags {
    Name = "sg-${var.vdc_name}"
  }
}

// module "sg_egress_all" {
//   source = "../sg/rule/egress_all"
//
//   sg_id = "${module.vpc_sg.sg_id}"


resource "aws_security_group_rule" "sg_rule" {
    type = "egress"
    from_port = "0"
    to_port = "65535"
    protocol = "all"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg.id}"
}

// module "vpc_dns_zone" {
//   source = "../route53/zone"
//
//   vpc_id = "${aws_vpc.vpc.id}"
//   domain = "${var.vdc_name}.${var.root_domain}"
// }
//
// resource "aws_s3_bucket" "secrets" {
//     bucket = "${var.vdc_name}.secrets"
//     acl = "private"
// }
//
// resource "aws_key_pair" "ec2_key" {
//   key_name = "${var.vdc_name}-key"
//   public_key = "${file("${path.module}/../../secrets/${var.vdc_name}_rsa.pub")}"
// }
