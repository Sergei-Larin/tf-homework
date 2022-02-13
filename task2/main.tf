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

data "aws_ami" "latest_aws_linux" {
	owners      = ["amazon"]
	most_recent = true
	filter {
		name  = "name"
		values = [
			"amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2",
		]
	}
}

resource "aws_security_group" "nginx_sg" {
    vpc_id = data.aws_vpc.current.id
    name   = "Nginx security group"
	description = "security group for nginx"

    dynamic "ingress" {
		for_each = var.ports
		content {
			from_port = ingress.value
			to_port = ingress.value
			protocol = "tcp"
			cidr_blocks = ["0.0.0.0/0"]
		}
    }
	
	egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
	
	tags =  merge (var.common_tags, {Name = "Allow connection to nginx"})	
}

resource "aws_instance" "nginx" {
    ami                    = data.aws_ami.latest_aws_linux.id
    instance_type          = "t2.micro"
    subnet_id              = data.aws_subnets.current.ids[0]
    security_groups	  	   = [aws_security_group.nginx_sg.id]
	  user_data 	 		       = file("user_data.sh")

    tags =  merge (var.common_tags, {Name = "WEB Server"})	
}

# ---------------------------------------------------------------------------------------------------------------------
# DATABASE INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "db_instance" {
	name   = "Database SG"
	vpc_id = data.aws_vpc.current.id
}

resource "aws_security_group_rule" "allow_db_access" {
	type              = "ingress"
	from_port         = var.port
	to_port           = var.port
	protocol          = "tcp"
	security_group_id = aws_security_group.db_instance.id
	cidr_blocks       = ["0.0.0.0/0"]
}

resource "random_string" "rds_password" {
	length 			 = 12
	special 		 = true
	override_special = "!#$&"
}

resource "aws_ssm_parameter" "rds_password" {
	name 		= var.rds_pass_key
	description = "Master Password for RDS"
	type 		= "SecureString"
	value		= random_string.rds_password.result
}

data "aws_ssm_parameter" "master_rds_password"{
	name 		= var.rds_pass_key
	depends_on = [aws_ssm_parameter.rds_password]
}

resource "aws_db_subnet_group" "db_subnets" {
	name       = "education"
	subnet_ids = [data.aws_subnets.current.ids[0], data.aws_subnets.current.ids[1], data.aws_subnets.current.ids[2]]
}

resource "aws_db_instance" "default" {
	identifier             = var.name
	allocated_storage      = var.allocated_storage
	engine                 = var.engine_name
	engine_version         = var.engine_version
	port                   = var.port
	name                   = var.db_name
	username               = var.db_username
	password               = data.aws_ssm_parameter.master_rds_password.value
	instance_class         = var.instance_class
	db_subnet_group_name   = aws_db_subnet_group.db_subnets.id
	vpc_security_group_ids = [aws_security_group.db_instance.id]
	skip_final_snapshot    = true
	publicly_accessible    = true

	tags =  merge (var.common_tags, {Name = "RDS database"})	
}