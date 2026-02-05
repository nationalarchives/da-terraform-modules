output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc" {
  value = aws_vpc.main
}

output "private_nacl_arn" {
  value = aws_network_acl.private_nacl.arn
}

output "public_nacl_arn" {
  value = aws_network_acl.public_nacl.arn
}

output "private_cidr_blocks" {
  value = local.private_cidr_blocks
}


