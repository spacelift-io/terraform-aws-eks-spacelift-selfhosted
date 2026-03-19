locals {
  node_groups    = var.eks_auto_mode_enabled ? null : var.eks_managed_node_groups
  inject_ebs_key = var.ebs_encryption.enabled && var.ebs_encryption.kms_key_arn == null
  node_groups_with_defaults = local.inject_ebs_key && local.node_groups != null ? {
    for name, ng in local.node_groups : name => merge(ng, ng.block_device_mappings != null ? {} : {
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            kms_key_id = aws_kms_key.ebs[0].arn
            encrypted  = true
          }
        }
      }
    })
  } : local.node_groups
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = var.eks_cluster_version
  upgrade_policy     = var.eks_upgrade_policy

  # The Kubernetes API endpoint will be accessible via the public internet.
  endpoint_public_access = true

  # Adds the current caller identity as an administrator via cluster access entry. This is required
  # in order to install the cluster addons.
  enable_cluster_creator_admin_permissions = true

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  # Enable EKS Auto mode using a general purpose node pool
  compute_config = {
    enabled    = var.eks_auto_mode_enabled
    node_pools = var.eks_auto_mode_enabled ? ["general-purpose"] : []
  }

  # When auto mode is disabled, the essential networking addons that auto mode
  # normally manages must be installed BEFORE node groups via before_compute.
  # Without this ordering, nodes deadlock: they need VPC CNI to pass health
  # checks, but the default addon resource waits for node groups to complete.
  addons = var.eks_auto_mode_enabled ? {} : {
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    kube-proxy = {
      most_recent    = true
      before_compute = true
    }
    coredns = {
      most_recent    = true
      before_compute = true
    }
  }

  eks_managed_node_groups = local.node_groups_with_defaults

  tags = {
    Name = "Spacelift cluster ${module.spacelift.unique_suffix}"
  }
}

# Allow the cluster nodes to access the database.
resource "aws_vpc_security_group_ingress_rule" "cluster_database_ingress_rule" {
  count = length(coalesce(module.spacelift.database_security_group_ids, []))

  security_group_id = module.spacelift.database_security_group_ids[count.index]

  description                  = "Only accept TCP connections on appropriate port from EKS cluster nodes"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.eks.cluster_primary_security_group_id
}
