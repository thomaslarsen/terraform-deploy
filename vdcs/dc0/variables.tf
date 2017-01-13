
variable "region"       { default = "eu-west-1" }

variable "vdc_name"     {

}

variable "vdc_subnet_size" {
  default = "18"
}

variable "vdc_index" {
}

variable "root_domain" {

}

variable "public_domain_prefix" {
  default = "aws"
}

variable "public_zone_id" {
  description = "The Route 53 zone ID for the public zone"
}
