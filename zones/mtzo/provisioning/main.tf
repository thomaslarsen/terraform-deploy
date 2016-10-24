
variable "test_ami"     { default = "ami-8b8c57f8" }

variable "key" {
  default = "TL"
}

variable "vpc_name" {
  default = "dc0"
}

variable "appzone_name" {
  default = "mtzo"
}

variable "kickstart_url" {

}

data "terraform_remote_state" "vpc" {
    backend = "local"
    config {
        path = "${path.module}/../../../vdcs/${var.vpc_name}/terraform.tfstate"
    }
}

data "terraform_remote_state" "zone" {
    backend = "local"
    config {
        path = "${path.module}/../../../zones/${var.appzone_name}/terraform.tfstate"
    }
}

provider "aws" {
  region = "${data.terraform_remote_state.vpc.region}"
}

#--------------------------------------------------------------
# Services
#--------------------------------------------------------------

module "saltmaster" {
  source = "../../../services/saltmaster"

  ami_id = "${var.test_ami}"
  key = "${var.key}"
  vpc_name = "${var.vpc_name}"
  appzone_name = "${var.appzone_name}"

  kickstart_url = "${var.kickstart_url}"
}
