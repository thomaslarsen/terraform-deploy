
variable "region"         { }

variable "vdc_name"       { }

variable "appzone_index"  { }

variable "class"          { }

variable "appzone_name" {
  default = "mtzo"
}

variable "appzone_3rd" {
  type = "list"
  default = [0,32,16,48,8,24,40,56,4,12,20,28,36,44,52,60]
}
