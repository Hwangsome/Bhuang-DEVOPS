resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy

  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}

resource "aws_internet_gateway" "this" {
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.name}-igw" },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    { "Name" = "${var.name}-public-${element(var.availability_zones, count.index)}" },
    var.tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    { "Name" = "${var.name}-private-${element(var.availability_zones, count.index)}" },
    var.tags
  )
}

resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? length(var.public_subnet_cidrs) : 0

  domain = "vpc"

  tags = merge(
    { "Name" = "${var.name}-nat-eip-${count.index}" },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? length(var.public_subnet_cidrs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    { "Name" = "${var.name}-nat-gw-${count.index}" },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.name}-public-rt" },
    var.tags
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_internet_gateway ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  count = var.create_internet_gateway ? length(var.public_subnet_cidrs) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count = var.create_nat_gateway ? length(var.private_subnet_cidrs) : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.name}-private-rt-${count.index}" },
    var.tags
  )
}

resource "aws_route" "private_nat_gateway" {
  count = var.create_nat_gateway ? length(var.private_subnet_cidrs) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.create_nat_gateway ? aws_route_table.private[count.index].id : aws_vpc.this.default_route_table_id
}
