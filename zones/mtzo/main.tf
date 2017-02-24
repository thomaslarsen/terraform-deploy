
data "terraform_remote_state" "vpc" {
    backend = "local"
    config {
        path = "${path.module}/../../state/${var.vdc_name}.vdcs.tfstate"
    }
}

provider "aws" {
  region = "${var.region}"
}
