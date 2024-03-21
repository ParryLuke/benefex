# Return default VPC
data "aws_vpc" "default" {
  default = true
}

# Return default subnets
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

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

# Retrieve default tags from provider for use in ASGs
data "aws_default_tags" "current" {}
