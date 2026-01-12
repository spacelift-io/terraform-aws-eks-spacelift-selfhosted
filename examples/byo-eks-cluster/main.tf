data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_dns_suffix = data.aws_partition.current.dns_suffix
  aws_partition  = data.aws_partition.current.partition

  # Replace with your EKS cluster OIDC issuer URL
  # If using terraform-aws-modules/eks/aws: module.eks.cluster_oidc_issuer_url
  # See: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v21.10.1/outputs.tf#L50
  oidc_provider    = try(aws_eks_cluster.this[0].identity[0].oidc[0].issuer, null)
  website_endpoint = "{your-server-domain}" # Example: spacelift.example.com

  drain_service_account_name     = "spacelift-drain"
  scheduler_service_account_name = "spacelift-scheduler"
  server_service_account_name    = "spacelift-server"
  namespace                      = "spacelift"
}

module "spacelift" {
  source             = "github.com/spacelift-io/terraform-aws-spacelift-selfhosted?ref=v2.0.0"
  region             = local.aws_region
  website_endpoint   = local.website_endpoint
  rds_engine_version = "17.7"
}

module "iam" {
  source                               = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted//modules/iam?ref=v3.0.0"
  aws_account_id                       = local.aws_account_id
  aws_dns_suffix                       = local.aws_dns_suffix
  aws_partition                        = local.aws_partition
  deliveries_bucket_name               = module.spacelift.deliveries_bucket_name
  drain_service_account_name           = local.drain_service_account_name
  kms_encryption_key_arn               = module.spacelift.kms_encryption_key_arn
  kms_key_arn                          = module.spacelift.kms_key_arn
  kms_signing_key_arn                  = module.spacelift.kms_signing_key_arn
  large_queue_messages_bucket_name     = module.spacelift.large_queue_messages_bucket_name
  metadata_bucket_name                 = module.spacelift.metadata_bucket_name
  modules_bucket_name                  = module.spacelift.modules_bucket_name
  namespace                            = local.namespace
  oidc_provider                        = local.oidc_provider
  policy_inputs_bucket_name            = module.spacelift.policy_inputs_bucket_name
  run_logs_bucket_name                 = module.spacelift.run_logs_bucket_name
  scheduler_service_account_name       = local.scheduler_service_account_name
  server_service_account_name          = local.server_service_account_name
  states_bucket_name                   = module.spacelift.states_bucket_name
  unique_suffix                        = module.spacelift.unique_suffix
  uploads_bucket_name                  = module.spacelift.uploads_bucket_name
  user_uploaded_workspaces_bucket_name = module.spacelift.user_uploaded_workspaces_bucket_name
  workspace_bucket_name                = module.spacelift.workspace_bucket_name
}

module "kube_outputs" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted//modules/kube-outputs?ref=v3.0.0"

  aws_region                           = local.aws_region
  database_read_only_url               = module.spacelift.database_read_only_url
  database_url                         = module.spacelift.database_url
  deliveries_bucket_name               = module.spacelift.deliveries_bucket_name
  drain_role_arn                       = module.iam.drain_role_arn
  ecr_backend_repository_url           = module.spacelift.ecr_backend_repository_url
  ecr_launcher_repository_url          = module.spacelift.ecr_launcher_repository_url
  kms_encryption_key_arn               = module.spacelift.kms_encryption_key_arn
  kms_signing_key_arn                  = module.spacelift.kms_signing_key_arn
  large_queue_messages_bucket_name     = module.spacelift.large_queue_messages_bucket_name
  metadata_bucket_name                 = module.spacelift.metadata_bucket_name
  modules_bucket_name                  = module.spacelift.modules_bucket_name
  policy_inputs_bucket_name            = module.spacelift.policy_inputs_bucket_name
  run_logs_bucket_name                 = module.spacelift.run_logs_bucket_name
  scheduler_role_arn                   = module.iam.scheduler_role_arn
  server_domain                        = local.website_endpoint
  server_role_arn                      = module.iam.server_role_arn
  states_bucket_name                   = module.spacelift.states_bucket_name
  uploads_bucket_name                  = module.spacelift.uploads_bucket_name
  uploads_bucket_url                   = module.spacelift.uploads_bucket_url
  user_uploaded_workspaces_bucket_name = module.spacelift.user_uploaded_workspaces_bucket_name
  workspace_bucket_name                = module.spacelift.workspace_bucket_name
}

output "kube_outputs" {
  value = module.kube_outputs
}
