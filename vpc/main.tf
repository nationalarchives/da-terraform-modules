locals {
  new_bits = tonumber(split("/", var.subnet_cidr_prefix)[1]) - tonumber(split("/", var.cidr_block)[1])
}

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = merge(
    var.tags,
    tomap(
      { "Name" = var.vpc_name }
    )
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, local.new_bits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-private-subnet-${data.aws_availability_zones.available.names[count.index]}" }
    )
  )
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, local.new_bits, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-public-subnet-${data.aws_availability_zones.available.names[count.index]}" }
    )
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_nat_gateway" "gw" {
  count         = length(var.elastic_ip_ids)
  subnet_id     = aws_subnet.public.*.id[count.index]
  allocation_id = var.elastic_ip_ids[count.index]

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-nat-gateway-${count.index}" }
    )
  )
}

resource "aws_route_table" "private_nat_gateway" {
  count  = length(var.elastic_ip_ids)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.*.id[count.index]
  }

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-route-table-${count.index}" }
    )
  )
}

resource "aws_route_table" "private_nat_instance" {
  count  = length(var.network_interface_ids)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = var.network_interface_ids[count.index]
  }

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-route-table-${count.index}" }
    )
  )
}

resource "aws_route_table_association" "private_nat_instance" {
  count     = length(var.network_interface_ids) > 0 ? var.az_count : 0
  subnet_id = aws_subnet.private.*.id[count.index]
  // If AZ count is higher than the number of ENI ids provided, assign all remaining subnets to the last ENI
  route_table_id = count.index > length(var.network_interface_ids) - 1 ? var.network_interface_ids[length(var.network_interface_ids) - 1] : var.network_interface_ids[count.index]
}

resource "aws_route_table_association" "private_nat_gateway" {
  count     = length(var.elastic_ip_ids) > 0 ? var.az_count : 0
  subnet_id = aws_subnet.private.*.id[count.index]
  // If AZ count is higher than the number of elastic IPs provided, assign all remaining subnets to the last NAT gateway
  route_table_id = count.index > length(var.elastic_ip_ids) - 1 ? aws_route_table.private_nat_gateway.*.id[length(var.elastic_ip_ids) - 1] : aws_route_table.private_nat_gateway.*.id[count.index]
}
