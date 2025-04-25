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
  subnet_ids = local.private_subnet_ids

  # Enable EKS Auto mode using a general purpose node pool
  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  tags = {
    Name = "Spacelift cluster ${module.spacelift.unique_suffix}"
  }
}

# Allow the cluster nodes to access the database.
resource "aws_vpc_security_group_ingress_rule" "cluster_database_ingress_rule" {
  security_group_id = module.spacelift.database_security_group_id

  description                  = "Only accept TCP connections on appropriate port from EKS cluster nodes"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.eks.cluster_primary_security_group_id
}
