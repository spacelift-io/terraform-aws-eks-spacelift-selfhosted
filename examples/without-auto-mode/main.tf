data "aws_rds_engine_version" "postgres" {
  engine = "aurora-postgresql"
  latest = true
}

data "aws_eks_cluster_versions" "this" {
  default_only = true
}

module "spacelift_eks_selfhosted" {
  source = "../../"

  aws_region          = var.aws_region
  server_domain       = "test.spacelift.example.com"
  rds_engine_version  = data.aws_rds_engine_version.postgres.version_actual
  eks_cluster_version = data.aws_eks_cluster_versions.this.cluster_versions[0].cluster_version

  eks_upgrade_policy = {
    support_type = "STANDARD"
  }

  # Disable EKS Auto Mode and use managed node groups instead
  eks_auto_mode_enabled = false

  eks_managed_node_groups = {
    spacelift = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.large"]
      min_size       = 1
      max_size       = 4
      desired_size   = 1
    }
  }

  # For easier test cleanup:
  rds_delete_protection_enabled = false
  s3_retain_on_destroy          = false
  ecr_force_delete              = true
  rds_instance_configuration    = {}
}
