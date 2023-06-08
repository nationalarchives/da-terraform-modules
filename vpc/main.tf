locals {
  new_bits           = tonumber(split("/", var.subnet_cidr_prefix)[1]) - tonumber(split("/", var.cidr_block)[1])
  ip_count           = length(var.elastic_ip_allocation_ids) == 0 ? var.az_count : length(var.elastic_ip_allocation_ids)
  count_nat_gateway  = var.use_nat_gateway ? local.ip_count : 0
  count_nat_instance = var.use_nat_gateway ? 0 : local.ip_count
  allocation_ids     = length(var.elastic_ip_allocation_ids) == 0 ? aws_eip.eip.*.allocation_id : var.elastic_ip_allocation_ids
}

resource "aws_eip" "eip" {
  count  = length(var.elastic_ip_allocation_ids) > 0 ? 0 : var.az_count
  domain = "vpc"
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
  count         = local.count_nat_gateway
  subnet_id     = aws_subnet.public.*.id[count.index]
  allocation_id = local.allocation_ids[count.index]

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-nat-gateway-${count.index}" }
    )
  )
}

resource "aws_route_table" "private_nat_gateway" {
  count  = local.count_nat_gateway
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
  count  = local.count_nat_instance
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance[count.index].primary_network_interface_id
  }

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-route-table-${count.index}" }
    )
  )
  depends_on = [aws_instance.nat_instance]
}

data "aws_ami" "ami" {
  count       = var.use_nat_gateway ? 0 : 1
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }
  owners = ["137112412989"]
}

resource "aws_instance" "nat_instance" {
  count             = local.count_nat_instance
  ami               = data.aws_ami.ami[0].id
  user_data         = templatefile("${path.module}/templates/nat_instance_user_data.sh.tpl", { vpc_cidr_range = aws_vpc.main.cidr_block })
  instance_type     = "t3.nano"
  source_dest_check = false

  iam_instance_profile        = aws_iam_instance_profile.instance_profile.id
  user_data_replace_on_change = true
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = var.nat_instance_security_groups
}

resource "aws_eip_association" "eip_assoc" {
  count         = local.count_nat_instance
  instance_id   = aws_instance.nat_instance[count.index].id
  allocation_id = local.allocation_ids[count.index]
}

resource "aws_iam_role" "instance_role" {
  assume_role_policy = templatefile("${path.module}/templates/ec2_assume_role.json.tpl", {})
  name               = "${var.vpc_name}-iam-role"
}

resource "aws_iam_role_policy_attachment" "instance_role_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.instance_role.name
}

resource "aws_iam_instance_profile" "instance_profile" {
  role = aws_iam_role.instance_role.name
  name = "${var.vpc_name}-instance-profile"
}

resource "aws_route_table_association" "private_nat_instance" {
  count     = local.count_nat_instance > 0 ? var.az_count : 0
  subnet_id = aws_subnet.private.*.id[count.index]
  // If AZ count is higher than the number of ENI ids provided, assign all remaining subnets to the last ENI
  route_table_id = count.index > local.count_nat_instance - 1 ? aws_route_table.private_nat_instance.*.id[local.count_nat_instance - 1] : aws_route_table.private_nat_instance.*.id[count.index]
}

resource "aws_route_table_association" "private_nat_gateway" {
  count     = local.count_nat_gateway > 0 ? var.az_count : 0
  subnet_id = aws_subnet.private.*.id[count.index]
  // If AZ count is higher than the number of elastic IPs provided, assign all remaining subnets to the last NAT gateway
  route_table_id = count.index > local.count_nat_gateway - 1 ? aws_route_table.private_nat_gateway.*.id[local.count_nat_gateway - 1] : aws_route_table.private_nat_gateway.*.id[count.index]
}
