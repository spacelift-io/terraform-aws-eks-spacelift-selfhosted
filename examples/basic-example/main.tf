data "aws_rds_engine_version" "postgres" {
  engine = "aurora-postgresql"
  latest = true
}

module "spacelift_eks_selfhosted" {
  source = "../../"

  aws_region         = var.aws_region
  server_domain      = "test.spacelift.example.com"
  rds_engine_version = data.aws_rds_engine_version.postgres.version_actual

  eks_upgrade_policy = {
    support_type = "STANDARD"
  }

  # For easier test cleanup:
  rds_delete_protection_enabled = false
  s3_retain_on_destroy          = false
  ecr_force_delete              = true
  rds_instance_configuration    = {}
}
