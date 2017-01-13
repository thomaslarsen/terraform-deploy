
provider "aws" {
  region = "${data.terraform_remote_state.vpc.region}"
}

data "terraform_remote_state" "vpc" {
    backend = "local"
    config {
        path = "${path.module}/../../state/${var.vdc_name}.vdcs.tfstate"
    }
}
