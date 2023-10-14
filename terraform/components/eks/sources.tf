data "aws_availability_zones" "current" {
  state = "available"
}

data "aws_vpc" "main" {
  filter {
    name = "tag:Name"
    values = [
      local.name
    ]
  }
}

data "aws_subnets" "private" {
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.main.id
    ]
  }

  tags = {
    Name = "*-private-${local.name}"
    type = "private"
  }
}

data "aws_subnets" "public" {
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.main.id
    ]
  }

  tags = {
    Name = "*-public-${local.name}"
    type = "public"
  }
}

data "http" "my_ip" {
  url = "https://v4.ident.me/"
}