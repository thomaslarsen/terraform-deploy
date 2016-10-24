output "id_az_a" {
  value = "${aws_subnet.subnet-az-a.id}"
}

output "id_az_b" {
  value = "${aws_subnet.subnet-az-b.id}"
}

output "cidr_az_a" {
  value = "${aws_subnet.subnet-az-a.cidr_block}"
}

output "cidr_az_b" {
  value = "${aws_subnet.subnet-az-b.cidr_block}"
}
