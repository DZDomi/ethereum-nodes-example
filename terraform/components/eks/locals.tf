locals {
  name = "poc"

  cluster_version = "1.28"

  worker_groups = {
    system = {
      instance_type = "t4g.medium"

      min_size     = 0
      max_size     = 3
      desired_size = 3

      subnet_ids = data.aws_subnets.private.ids
    }
    nodes = {
      # Note: Reference here:
      # https://geth.ethereum.org/docs/getting-started/hardware-requirements
      # Quad core/16gb RAM. Can ofc be changed if more load is expected
      instance_type = "m7g.xlarge"

      min_size     = 0
      max_size     = 1
      desired_size = 1

      # Note: Blockchain nodes need to be in a public subnet for p2p networking
      subnet_ids = data.aws_subnets.public.ids
    }
  }
}