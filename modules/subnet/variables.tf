variable "region" {

}

variable "name" {
  description = "The name of the subnet"
}

variable "vpc_id" {

}

variable "map_public_ip" {
  default = false
}

variable "route_table_id" {
  description = "Route table to add the subnet to"
}

variable "slot" {

}

variable "octet2" {
  description = "The 2nd octed of the VPCs CIDR"
}

variable "octet3" {
  description = "The 3rd octed of the VPCs CIDR"
}

variable "size" {
  default = "26"
}
