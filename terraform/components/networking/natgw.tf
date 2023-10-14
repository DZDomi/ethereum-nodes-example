module "natgw" {
  for_each = local.nat_gateway_subnets
  source   = "../../modules/natgw"

  name = local.name

  availability_zone = each.key
  subnet_id         = module.subnets_natgw[each.key].id
}