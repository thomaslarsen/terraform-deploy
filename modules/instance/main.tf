variable "ami_id" {
  default = "ami-8b8c57f8"
}

variable "instance_type" {
}

variable "service" {
}

variable "role" {
}

variable "hostname" {
}

variable "appzone_name" {
}

variable "userdata" {

}
variable "vpc_id" {
}

variable "subnet_list" {
  type = "list"
}

variable "az_index" {
  default = 0
}

variable "key_name" {
}

variable "sg_list" {
  type = "list"
}

variable "domain" {
}

variable "zone_id" {
}

# --------------------------------
# Create Security Groups
# --------------------------------
module "service_sg" {
  source = "../sg"

  vpc_id = "${var.vpc_id}"
  name = "${var.service}"
}

resource "aws_instance" "instance" {
  ami             = "${var.ami_id}"
  instance_type   = "${var.instance_type}"
  subnet_id       = "${element(var.subnet_list, var.az_index)}"
  key_name        = "${var.key_name}"
  vpc_security_group_ids = [
    "${concat(
      list(
        "${module.service_sg.sg_id}"
      ),
      "${var.sg_list}"
    )}"]

  tags = {
    Name        = "${var.service}-${var.appzone_name}"
    Hostname    = "${var.hostname}"
    FQDN        = "${var.hostname}.${var.appzone_name}.${var.domain}"
    Service     = "${var.service}"
    role        = "${var.role}"
  }

  user_data = "${var.userdata}"

  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------
# Create DNS record
# --------------------------------
module "service_dns" {
  source = "../route53/record"

  zone_id = "${var.zone_id}"
  ip = "${aws_instance.instance.private_ip}"
  name = "${var.hostname}.${var.appzone_name}.${var.domain}"
}

output "private_ip" {
  value = "${aws_instance.instance.private_ip}"
}

output "public_ip" {
  value = "${aws_instance.instance.public_ip}"
}

output "instance_id" {
   value = "${aws_instance.instance.id}"
}

output "sg_id" {
  value = "${module.service_sg.sg_id}"
}

output "fqdn" {
  value = "${var.hostname}.${var.appzone_name}.${var.domain}"
}
