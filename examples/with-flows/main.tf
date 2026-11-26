module "spacelift_eks_selfhosted" {
  source = "../../"

  aws_region         = "us-east-1"
  server_domain      = "deploy.spacelift.io"
  rds_engine_version = "18.6"
  license_token      = "<your-license-token>"

  flows = {
    domain            = "flows.spacelift.io"
    acm_arn           = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"
    organization_name = "Spacelift"
    admin_email       = "admin@spacelift.io"
    admin_password    = "<your-admin-password-of-at-least-32-characters>"
  }
}
