
provider "aws" {
  region = "${var.region}"
}

data "null_data_source" "net" {
# Calculate the VPC subnet octets
  inputs = {
    vpc_2nd_octet = "${var.vdc_index * 16 + 16}"

    vpc_3rd_octet = "${(64 * (var.vdc_index / 16)) % 256}"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name = "${var.vdc_name}"
  cidr = "10.${data.null_data_source.net.inputs.vpc_2nd_octet}.${data.null_data_source.net.inputs.vpc_3rd_octet}.0/${var.vdc_subnet_size}"
  root_domain = "${var.root_domain}"
}

resource "aws_key_pair" "ec2_key" {
  key_name = "${var.vdc_name}-key"
  public_key = "${file("${path.module}/../../secrets/${var.vdc_name}_rsa.pub")}"
}
