module "subnets_private" {
  for_each = local.private_subnets
  source   = "../../modules/subnet"

  name = local.name

  availability_zone = each.key
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  gateway_id        = module.natgw[each.key].id

  type = "private"
}

module "subnets_public" {
  for_each = local.public_subnets
  source   = "../../modules/subnet"

  name = local.name

  availability_zone = each.key
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  gateway_id        = aws_internet_gateway.main.id

  type = "public"
}

module "subnets_natgw" {
  for_each = local.nat_gateway_subnets
  source   = "../../modules/subnet"

  name = "${local.name}-natgw"

  availability_zone = each.key
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  gateway_id        = aws_internet_gateway.main.id

  type = "public"
}