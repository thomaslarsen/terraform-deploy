
variable "vdc_name" {
  default = "dc0"
}

variable "appzone_name" {
  default = "mtzo"
}

variable "appzone_index" {
  default = 0
}

variable "appzone_3rd" {
  type = "list"
  default = [0,32,16,48,8,24,40,56,4,12,20,28,36,44,52,60]
}

variable "class" {
  default = "dev"
}
