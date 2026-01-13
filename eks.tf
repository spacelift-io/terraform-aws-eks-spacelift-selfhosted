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
    enabled    = true
    node_pools = ["general-purpose"]
  }

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
