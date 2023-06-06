output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "private_route_table_ids" {
  value = length(aws_route_table.private_nat_gateway) == 0 ? aws_route_table.private_nat_instance.*.id : aws_route_table.private_nat_gateway.*.id
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "cloud_init" {
  value = data.cloudinit_config.user_data_config.rendered
}
