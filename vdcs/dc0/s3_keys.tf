resource "aws_s3_bucket_object" "ssh_public_key" {
    bucket = "${module.vpc.secrets_bucket_id}"
    key = "keys/ssh/public.pub"
    source = "${path.module}/../../secrets/${var.vdc_name}_rsa.pub"
}

resource "aws_s3_bucket_object" "ssh_private_key" {
    bucket = "${module.vpc.secrets_bucket_id}"
    key = "keys/ssh/private"
    source = "${path.module}/../../secrets/${var.vdc_name}_rsa"
}
