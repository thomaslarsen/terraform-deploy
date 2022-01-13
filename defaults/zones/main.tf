variable "region"         { }

variable "vdc_name"       { }

variable "appzone_index"  { }

variable "class"          { }

variable "appzone_name"   { }

variable "appzone_3rd" {
  type = "list"
  default = [0,32,16,48,8,24,40,56,4,12,20,28,36,44,52,60]
}

output "appzone_name" {
  value = "${var.appzone_name}"
}

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
