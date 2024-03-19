# Return list of available zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Return the latest AMI compatible with the MATE desktop for RDP
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-x86_64-MATE*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
