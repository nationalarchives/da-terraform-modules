locals {
  new_bits           = tonumber(split("/", var.subnet_cidr_prefix)[1]) - tonumber(split("/", var.cidr_block)[1])
  nat_gateway_count  = var.create_nat_gateway ? length(var.elastic_ip_ids) : 0
  nat_instance_count = var.create_nat_gateway ? 0 : length(var.elastic_ip_ids)
}

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
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
  count         = local.nat_gateway_count
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
  count  = local.nat_gateway_count
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.*.id[count.index]
  }
  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-nat-gateway-route-table-${count.index}" }
    )
  )
}

resource "aws_route_table" "private_nat_instance" {
  count  = local.nat_instance_count
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-nat-instance-route-table-${count.index}" }
    )
  )
}

locals {
  vpc_az_maps = [
    for index, rt in aws_route_table.private_nat_instance.*.id
    : {
      az                 = aws_subnet.public[index].availability_zone
      route_table_ids    = [rt]
      public_subnet_id   = aws_subnet.public[index].id
      private_subnet_ids = [aws_subnet.private[index].id]
    }
  ]
}

data "aws_network_interface" "interface" {
  count = local.nat_instance_count
  filter {
    name   = "association.allocation-id"
    values = [var.elastic_ip_ids[count.index]]
  }
  depends_on = [module.alternat_instances]
}

resource "aws_route" "nat_instance_route" {
  count                  = local.nat_instance_count
  route_table_id         = aws_route_table.private_nat_instance[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = data.aws_network_interface.interface[count.index].id
  depends_on             = [module.alternat_instances]
}

module "alternat_instances" {
  count                         = var.create_nat_gateway ? 0 : 1
  source                        = "git::https://github.com/1debit/alternat.git//modules/terraform-aws-alternat?ref=v0.4.2"
  lambda_package_type           = "Zip"
  ingress_security_group_ids    = [var.nat_instance_settings.security_group]
  vpc_id                        = aws_vpc.main.id
  vpc_az_maps                   = local.vpc_az_maps
  create_nat_gateways           = false
  nat_instance_type             = var.nat_instance_settings.nat_instance_type
  nat_instance_iam_profile_name = var.nat_instance_settings.nat_instance_iam_profile_name
  nat_instance_iam_role_name    = var.nat_instance_settings.nat_instance_iam_role_name
  nat_instance_eip_ids          = var.elastic_ip_ids
  nat_instance_block_devices = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        encrypted   = true
        volume_type = "gp3"
        volume_size = 20
      }
    }
  }
}

resource "aws_route_table_association" "private_nat_gateway" {
  count     = local.nat_gateway_count > 0 ? var.az_count : 0
  subnet_id = aws_subnet.private.*.id[count.index]
  // If AZ count is higher than the number of elastic IPs provided, assign all remaining subnets to the last NAT gateway
  route_table_id = count.index > length(var.elastic_ip_ids) - 1 ? aws_route_table.private_nat_gateway.*.id[length(var.elastic_ip_ids) - 1] : aws_route_table.private_nat_gateway.*.id[count.index]
}

resource "aws_route_table_association" "private_nat_instance" {
  count     = local.nat_instance_count > 0 ? var.az_count : 0
  subnet_id = aws_subnet.private.*.id[count.index]
  // If AZ count is higher than the number of elastic IPs provided, assign all remaining subnets to the last NAT gateway
  route_table_id = count.index > length(var.elastic_ip_ids) - 1 ? aws_route_table.private_nat_instance.*.id[length(var.elastic_ip_ids) - 1] : aws_route_table.private_nat_instance.*.id[count.index]
}
