
data "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "global.terraform"
        key = "state/vdcs/${var.vdc_name}.tfstate"
        region = "${var.region}"
    }
}

provider "aws" {
  region = "${var.region}"
}
