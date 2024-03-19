variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "name_prefix" {
  type    = string
  default = "blog"
}

variable "office_ip" {
  type    = string
  default = "80.193.23.74/32"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 2
}

variable "volume_size" {
  type    = number
  default = 20
}

variable "default_tags" {
  type = map(string)
  default = {
    Environment = "techBlog"
  }
}

variable "default_tag_asg_label" {
  type    = string
  default = "Environment"
}

variable "default_tag_asg_value" {
  type    = string
  default = "techBlog"
}
