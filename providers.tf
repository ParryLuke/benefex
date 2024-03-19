terraform {
  required_providers {
    aws = {
      source = "aws"

      # Avoid breaking changes
      version = "~> 5.41.0"
    }
  }
}

provider "aws" {
  region = var.region

  # Default tags for resources, applies to all resources except ASGs
  default_tags {
    tags = {
      Environment = "techBlog"
    }
  }
}
