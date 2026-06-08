
resource "aws_subnet" "public" {
  #checkov:skip=CKV_AWS_130: Public subnets host the internet-facing ALB and NAT gateways by design
  for_each = local.public_subnet_map

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = each.value.name
    Tier = "public"
  })
}

resource "aws_subnet" "web_private" {
  for_each = local.web_subnet_map

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name = each.value.name
    Tier = "private"
  })
}

resource "aws_subnet" "app_private" {
  for_each = local.app_subnet_map

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name = each.value.name
    Tier = "private"
  })
}

resource "aws_subnet" "db_private" {
  for_each = local.db_subnet_map

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name = each.value.name
    Tier = "private"
  })
}
