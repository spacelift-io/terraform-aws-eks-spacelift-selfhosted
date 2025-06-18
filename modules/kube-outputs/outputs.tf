data "aws_caller_identity" "current" {}

output "kubernetes_ingress_class" {
  description = "Generates an IngressClassParameters and IngressClass resource to configure the server load balancer. This output is just included as a convenience for use as part of the EKS getting started guide."
  value = templatefile("${path.module}/kubernetes-ingress-class.tftpl", {
    PUBLIC_SUBNET_IDS = var.public_subnet_ids
    SERVER_ACM_ARN    = var.server_acm_arn != null ? var.server_acm_arn : ""
  })
}

output "kubernetes_secrets" {
  sensitive   = true
  description = "Kubernetes secrets required for the Spacelift services. This output is just included as a convenience for use as part of the EKS getting started guide."
  value = templatefile("${path.module}/kubernetes-secrets.tftpl", {
    namespace                                      = var.k8s_namespace
    AWS_ACCOUNT_ID                                 = data.aws_caller_identity.current.account_id
    AWS_REGION                                     = var.aws_region
    SERVER_DOMAIN                                  = var.server_domain
    MQTT_BROKER_DOMAIN                             = coalesce(var.mqtt_broker_domain, "spacelift-mqtt.${var.k8s_namespace}.svc.cluster.local")
    ENCRYPTION_TYPE                                = "kms"
    ENCRYPTION_KMS_ENCRYPTION_KEY_ID               = var.kms_encryption_key_arn
    ENCRYPTION_KMS_SIGNING_KEY_ID                  = var.kms_signing_key_arn
    OBJECT_STORAGE_BUCKET_DELIVERIES               = var.deliveries_bucket_name
    OBJECT_STORAGE_BUCKET_LARGE_QUEUE_MESSAGES     = var.large_queue_messages_bucket_name
    OBJECT_STORAGE_BUCKET_MODULES                  = var.modules_bucket_name
    OBJECT_STORAGE_BUCKET_POLICY_INPUTS            = var.policy_inputs_bucket_name
    OBJECT_STORAGE_BUCKET_RUN_LOGS                 = var.run_logs_bucket_name
    OBJECT_STORAGE_BUCKET_STATES                   = var.states_bucket_name
    OBJECT_STORAGE_BUCKET_USER_UPLOADED_WORKSPACES = var.user_uploaded_workspaces_bucket_name
    OBJECT_STORAGE_BUCKET_WORKSPACE                = var.workspace_bucket_name
    OBJECT_STORAGE_BUCKET_METADATA                 = var.metadata_bucket_name
    OBJECT_STORAGE_BUCKET_UPLOADS                  = var.uploads_bucket_name
    OBJECT_STORAGE_BUCKET_UPLOADS_URL              = var.uploads_bucket_url
    DATABASE_URL                                   = var.database_url
    DATABASE_READ_ONLY_URL                         = var.database_read_only_url
    LICENSE_TOKEN                                  = var.license_token != null ? var.license_token : ""
    SPACELIFT_PUBLIC_API                           = var.spacelift_public_api != null ? var.spacelift_public_api : ""
    WEBHOOKS_ENDPOINT                              = "https://${var.server_domain}/webhooks"
    LAUNCHER_IMAGE                                 = var.ecr_launcher_repository_url
    SPACELIFT_VERSION                              = var.spacelift_version != null ? var.spacelift_version : ""
    ADMIN_USERNAME                                 = var.admin_username != null ? var.admin_username : ""
    ADMIN_PASSWORD                                 = var.admin_password != null ? var.admin_password : ""
  })
}

output "helm_values" {
  description = "Generates a Helm values.yaml file that can be used when deploying Spacelift. This output is just included as a convenience for use as part of the EKS getting started guide."
  value = templatefile("${path.module}/helm-values.tftpl", {
    SERVER_DOMAIN     = var.server_domain
    BACKEND_IMAGE     = var.ecr_backend_repository_url
    SPACELIFT_VERSION = var.spacelift_version != null ? var.spacelift_version : ""

    # Server
    SERVER_SERVICE_ACCOUNT_NAME = var.server_service_account_name
    SERVER_ROLE_ARN             = var.server_role_arn

    # Drian
    DRAIN_SERVICE_ACCOUNT_NAME = var.drain_service_account_name
    DRAIN_ROLE_ARN             = var.drain_role_arn

    # Scheduler
    SCHEDULER_SERVICE_ACCOUNT_NAME = var.scheduler_service_account_name
    SCHEDULER_ROLE_ARN             = var.scheduler_role_arn

    # Ingress
    SERVER_ACM_ARN = var.server_acm_arn != null ? var.server_acm_arn : ""

    # MQTT
    EXTERNAL_WORKERS_ENABLED = var.mqtt_broker_domain != null && var.mqtt_broker_domain != ""
  })
}