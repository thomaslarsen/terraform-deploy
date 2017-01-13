output "id" {
  value = ["${aws_subnet.subnet.*.id}"]
}

output "cidr" {
  value = ["${aws_subnet.subnet.*.cidr_block}"]
}
