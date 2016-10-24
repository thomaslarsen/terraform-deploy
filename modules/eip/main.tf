
resource "aws_eip" "eip" {
  vpc      = true

  lifecycle {
    create_before_destroy = true
  }
}

output "eip_id" {
  value = "${aws_eip.eip.id}"
}

output "public_ip" {
  value = "${aws_eip.eip.public_ip}"
}
