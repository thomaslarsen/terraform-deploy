variable "vpc_name" {

}

variable "appzone_name" {

}

variable "ami_id" {

}

variable "instance_type" {

}

variable "name" {

}

variable "key" {

}

variable "min_size" {
  default = "1"
}

variable "max_size" {
  default = "1"
}

variable "subnets" {
  type = "list"
}

resource "aws_launch_configuration" "as_conf" {
  name = "lc-${var.vpc_name}-${var.appzone_name}-${var.name}"
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "asg-${var.vpc_name}-${var.appzone_name}-${var.name}"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  vpc_zone_identifier = ["${var.subnets}"]

  lifecycle {
    create_before_destroy = true
  }
}
