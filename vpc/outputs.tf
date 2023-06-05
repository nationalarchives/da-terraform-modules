output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "private_route_table_ids" {
  value = merge(aws_route_table.private_nat_gateway.*.id, aws_route_table.private_nat_instance.*.id)
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
