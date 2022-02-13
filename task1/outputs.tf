output "aws_availability_zones" {
  value = data.aws_availability_zones.working.names
}

output "aws_region_name" {
  value = data.aws_region.current.name
}

output "aws_region_description" {
  value = data.aws_region.current.description
}

output "aws_vpc_id" {
  value = data.aws_vpc.current.id
}

output "aws_vpc_cidr_block" {
  value = data.aws_vpc.current.cidr_block
}

output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.current : s.cidr_block]
}

output "subnet_ids" {
  value = data.aws_subnets.current.ids
}

output "aws_security_groups" {
  value = data.aws_security_groups.current.ids
}