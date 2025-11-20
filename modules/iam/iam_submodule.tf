module "iam_roles_and_policies" {
  source = "github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted?ref=v1.3.1"

  write_as_files = false
  kubernetes_role_assumption_config = {
    aws_account_id                   = var.aws_account_id
    oidc_provider                    = var.oidc_provider
    namespace                        = var.namespace
    server_service_account_name      = var.server_service_account_name
    drain_service_account_name       = var.drain_service_account_name
    scheduler_service_account_name   = var.scheduler_service_account_name
    vcs_gateway_service_account_name = "unsupported-today-but-required-for-future-compatibility"
  }

  aws_partition = var.aws_partition

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

  sqs_queues = var.create_sqs ? {
    deadletter      = local.deadletter_queue_arn
    deadletter_fifo = local.deadletter_fifo_queue_arn
    async_jobs      = local.async_jobs_queue_arn
    async_jobs_fifo = local.async_jobs_fifo_queue_arn
    events_inbox    = local.events_inbox_queue_arn
    cronjobs        = local.cronjobs_queue_arn
    webhooks        = local.webhooks_queue_arn
    iot             = local.iot_queue_arn
  } : null
}
