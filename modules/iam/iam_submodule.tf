module "iam_roles_and_policies" {
  source = "file:///Users/adamc/github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted"
  # source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.0.1"

  write_as_files                    = false
  enable_ecs_role_assumption        = false
  enable_kubernetes_role_assumption = true
  kubernetes_config = {
    aws_account_id                 = var.aws_account_id
    oidc_provider                  = var.oidc_provider
    namespace                      = var.namespace
    server_service_account_name    = var.server_service_account_name
    drain_service_account_name     = var.drain_service_account_name
    scheduler_service_account_name = var.scheduler_service_account_name
  }

  aws_partition  = var.aws_partition
  aws_dns_suffix = var.aws_dns_suffix

  kms_encryption_key_arn = var.kms_encryption_key_arn
  kms_signing_key_arn    = var.kms_signing_key_arn
  kms_key_arn            = var.kms_key_arn

  deliveries_bucket_name               = var.deliveries_bucket_name
  large_queue_messages_bucket_name     = var.large_queue_messages_bucket_name
  metadata_bucket_name                 = var.metadata_bucket_name
  modules_bucket_name                  = var.modules_bucket_name
  policy_inputs_bucket_name            = var.policy_inputs_bucket_name
  run_logs_bucket_name                 = var.run_logs_bucket_name
  states_bucket_name                   = var.states_bucket_name
  uploads_bucket_name                  = var.uploads_bucket_name
  user_uploaded_workspaces_bucket_name = var.user_uploaded_workspaces_bucket_name
  workspace_bucket_name                = var.workspace_bucket_name
}
