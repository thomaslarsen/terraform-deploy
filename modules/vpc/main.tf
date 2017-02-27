resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "ig-${var.name}"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"
  }

  tags {
    Name = "rt-${var.name}-default"
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "vpc_sg" {
  source = "../sg"

  vpc_id = "${aws_vpc.vpc.id}"
  name = "${var.name}"
  description = "Security Group for VPC ${var.name}"
}

module "sg_egress_all" {
  source = "../sg/rule/egress_all"

  sg_id = "${module.vpc_sg.sg_id}"
}

module "vpc_dns_zone" {
  source = "../route53/zone"

  vpc_id = "${aws_vpc.vpc.id}"
  domain = "${var.name}.${var.root_domain}"
}

resource "aws_s3_bucket" "secrets" {
    bucket = "${var.name}.secrets"
    acl = "private"
}
