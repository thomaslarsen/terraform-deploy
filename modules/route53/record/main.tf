variable "zone_id" {

}

variable "ip" {

}

variable "name" {

}

variable "ttl" {
  default = "300"
}

resource "aws_route53_record" "record" {
   zone_id = "${var.zone_id}"
   name = "${var.name}"
   type = "A"
   ttl = "${var.ttl}"
   records = ["${var.ip}"]
}

output "fqdn" {
  value = "${aws_route53_record.record.fqdn}"
}
