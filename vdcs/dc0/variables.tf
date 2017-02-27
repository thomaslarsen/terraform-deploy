
variable "region"       { }

variable "vdc_name"     { }

variable "vdc_index"    { }

variable "root_domain"  { }

variable "vdc_subnet_size" {
  default = "18"
}

variable "public_domain_prefix" {
  default = "aws"
}

variable "public_zone_id" {
  description = "The Route 53 zone ID for the public zone"
}
