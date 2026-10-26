locals {
  name = "ethereum-nodes-example"

  # Note: Arbitrary chosen, in a real setup you would have to make
  # sure to avoid any ip range collisions between different environments
  cidr_block = "10.5.0.0/16"

  # /20 nets, per AZ, which should give us 3 * 4096 -> 12288 IPs per subnet type (private/public)
  # Note: Also here: this is just an assumption in reality these
  # values depend on on different factors, like expected server count/growth etc.
  private_subnets = {
    for index, zone in data.aws_availability_zones.current.names : zone => cidrsubnet(local.cidr_block, 4, index)
  }
  public_subnets = {
    for index, zone in data.aws_availability_zones.current.names : zone => cidrsubnet(local.cidr_block, 4, length(data.aws_availability_zones.current.names) + index)
  }

  # Some small /28 networks at the end of the last /24 block, for smaller gateways for connections outside of the VPC
  nat_gateway_subnets = {
    for index, zone in data.aws_availability_zones.current.names : zone => cidrsubnet(cidrsubnet(local.cidr_block, 8, 255), 4, index)
  }
}