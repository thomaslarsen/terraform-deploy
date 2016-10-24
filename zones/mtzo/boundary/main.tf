
variable "test_ami"     { default = "ami-8b8c57f8" }

variable "vpc_name" {
  default = "dc0"
}

variable "appzone_name" {
  default = "mtzo"
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

module "jump" {
  source = "../../../services/jump"

  ami_id = "${var.test_ami}"
  vpc_name = "${var.vpc_name}"
  appzone_name = "${var.appzone_name}"
}


module "dummy" {
  source = "../../../services/blank"

  hostname = "dummy"
  service = "dummy"

  ami_id = "${var.test_ami}"
  vpc_name = "${var.vpc_name}"
  appzone_name = "${var.appzone_name}"
  subnet_id = "${data.terraform_remote_state.zone.subnet_dmz_az_a_id}"
}
