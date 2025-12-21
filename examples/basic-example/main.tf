module "spacelift_eks_selfhosted" {
  source = "../../"

  aws_region          = var.aws_region
  server_domain       = "test.spacelift.example.com"
  eks_cluster_version = "1.34"
  rds_engine_version  = "17.7"

  # For easier test cleanup:
  rds_delete_protection_enabled = false
  s3_retain_on_destroy          = false
  ecr_force_delete              = true
  rds_instance_configuration    = {}
}
