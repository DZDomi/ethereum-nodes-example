resource "aws_vpc" "main" {
  cidr_block = local.cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.name
  }
}