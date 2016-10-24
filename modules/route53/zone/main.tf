variable "domain" {

}

variable "vpc_id" {

}

variable "force_destroy" {
  default = true
}

resource "aws_route53_zone" "zone" {
  name = "${var.domain}"
  vpc_id = "${var.vpc_id}"
  force_destroy = "${var.force_destroy}"
}

output "zone_id" {
  value = "${aws_route53_zone.zone.zone_id}"
}

output "name_servers" {
  value = "${aws_route53_zone.zone.name_servers}"
}
