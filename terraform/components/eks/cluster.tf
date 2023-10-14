module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.2"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id     = data.aws_vpc.main.id
  subnet_ids = concat(data.aws_subnets.private.ids, data.aws_subnets.public.ids)

  # Normally they should only be in private subnets and never be public!
  # This is only for this example, so we do not need to run a bastion host or similar
  control_plane_subnet_ids       = data.aws_subnets.public.ids
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = [
    local.my_ip
  ]

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.eks_addon_aws_ebs_csi_driver.iam_role_arn
    }
    vpc-cni = {
      most_recent              = true
      before_compute           = true
      service_account_role_arn = module.eks_addon_vpc_cni.iam_role_arn
    }
  }


  eks_managed_node_group_defaults = {
    ami_type = "BOTTLEROCKET_ARM_64"
    platform = "bottlerocket"

    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    for name, group in local.worker_groups : name => {
      name = "eks-${name}"

      instance_types = [
        group.instance_type
      ]

      min_size     = group.min_size
      max_size     = group.max_size
      desired_size = group.desired_size

      disk_size = 50

      subnet_ids = group.subnet_ids

      labels = {
        name = name
      }
    }
  }

  node_security_group_additional_rules = {
    allow_p2p_execution_client_udp = {
      description = "Allow connection from p2p udp for execution client"
      protocol    = "UDP"
      from_port   = 30303
      to_port     = 30303
      type        = "ingress"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      ipv6_cidr_blocks = [
        "::/0"
      ]
    }
    allow_p2p_execution_client_tcp = {
      description = "Allow connection from p2p tcp for execution client"
      protocol    = "TCP"
      from_port   = 30303
      to_port     = 30303
      type        = "ingress"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      ipv6_cidr_blocks = [
        "::/0"
      ]
    }
    allow_p2p_consensus_client_udp = {
      description = "Allow connection from p2p udp for consensus client"
      protocol    = "UDP"
      from_port   = 30400
      to_port     = 30400
      type        = "ingress"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      ipv6_cidr_blocks = [
        "::/0"
      ]
    }
    allow_p2p_consensus_client_tcp = {
      description = "Allow connection from p2p tcp for consensus client"
      protocol    = "TCP"
      from_port   = 30500
      to_port     = 30500
      type        = "ingress"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      ipv6_cidr_blocks = [
        "::/0"
      ]
    }
  }

  # Disabled for cost savings, in production should obviously be enabled
  cluster_enabled_log_types = []

  tags = {
    Name = local.name
  }
}