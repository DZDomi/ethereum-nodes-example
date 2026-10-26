resource "aws_subnet" "this" {
  availability_zone = var.availability_zone
  vpc_id            = var.vpc_id

  cidr_block              = var.cidr_block
  map_public_ip_on_launch = var.type == "public"

  tags = {
    Name = "${var.availability_zone}-${var.type}-${var.name}"
    type = var.type
  }
}

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.availability_zone}-${var.type}-${var.name}"
  }
}


resource "aws_route" "natgw_route_to_internet" {
  count = var.type == "private" ? 1 : 0

  route_table_id = aws_route_table.this.id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.gateway_id
}

resource "aws_route" "route_to_internet" {
  count = var.type == "public" ? 1 : 0

  route_table_id = aws_route_table.this.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.gateway_id
}

resource "aws_route_table_association" "this" {
  route_table_id = aws_route_table.this.id
  subnet_id      = aws_subnet.this.id
}