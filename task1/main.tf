terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 3.0"
		}	    	    
	}
	required_version = "~> 1.0"
}

provider "aws" {
    region = var.default_aws_region
}

data "aws_availability_zones" "working"{}
data "aws_region" "current"{}
data "aws_vpc" "current" {}

data "aws_subnets" "current" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.current.id]
  }
}

data "aws_subnet" "current" {
  for_each = toset(data.aws_subnets.current.ids)
  id       = each.value
}


data "aws_security_groups" "current" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.current.id]
  }
}
