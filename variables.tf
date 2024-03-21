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
  default = "xxx"
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

variable "volume_details" {
  type = list(object({
    device_name = string
    volume_size = number
    snapshot_id = string
  }))
  default = [
    {
      device_name = "/dev/sdb"
      volume_size = 5
      snapshot_id = "" # Empty or snapshot ID
    }
    # Add more volumes as needed
  ]
}
