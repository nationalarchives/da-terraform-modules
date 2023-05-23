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
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, var.new_bits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-private-subnet-${count.index}" }
    )
  )
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, var.new_bits, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-public-subnet-${count.index}" }
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

resource "aws_eip" "gw" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.gw]

  tags = merge(
    var.tags
  )
}

resource "aws_nat_gateway" "gw" {
  count         = var.az_count
  subnet_id     = aws_subnet.public.*.id[count.index]
  allocation_id = aws_eip.gw.*.id[count.index]

  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.vpc_name}-nat-gateway-${count.index}" }
    )
  )
}

resource "aws_route_table" "private" {
  count  = var.az_count
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

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.*.id[count.index]
}
