locals {
  eks_managed_node_group_defaults = coalesce(var.eks_managed_node_group_defaults, {
    subnet_ids                            = local.private_subnet_ids
    attach_cluster_primary_security_group = true
  })

  eks_managed_node_groups = coalesce(var.eks_managed_node_groups, {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7a.large"]
      min_size       = 0
      max_size       = 10
      desired_size   = 2
      capacity_type  = "ON_DEMAND"
    }
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version

  bootstrap_self_managed_addons = false

  # The Kubernetes API endpoint will be accessible via the public internet.
  cluster_endpoint_public_access = true

  # Adds the current caller identity as an administrator via cluster access entry. This is required
  # in order to install the cluster addons.
  enable_cluster_creator_admin_permissions = true

  vpc_id     = local.vpc_id
  subnet_ids = concat(local.public_subnet_ids, local.private_subnet_ids)

  # Node group configuration
  eks_managed_node_group_defaults = local.eks_managed_node_group_defaults
  eks_managed_node_groups         = local.eks_managed_node_groups

  tags = {
    Name = "Spacelift cluster ${module.spacelift.unique_suffix}"
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          # Enable pod network interfaces to add support for security groups per pod (https://docs.aws.amazon.com/eks/latest/best-practices/sgpp.html)
          ENABLE_POD_ENI                    = "true"
          AWS_VPC_K8S_CNI_EXTERNALSNAT      = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
      })
    }
    kube-proxy = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller = true
  observability_tag                   = null
}
