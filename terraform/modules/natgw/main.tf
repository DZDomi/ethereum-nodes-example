resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "${var.availability_zone}-${var.name}"
  }
}

resource "aws_nat_gateway" "this" {
  subnet_id     = var.subnet_id
  allocation_id = aws_eip.this.id

  tags = {
    Name = "${var.availability_zone}-${var.name}"
  }
}