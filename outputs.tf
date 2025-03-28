# TODO(adamc): add all outputs
# TODO(adamc): add shell output
output "shell" {
  sensitive = true
  value = templatefile("${path.module}/env.tftpl", {
    env : {
      AWS_ACCOUNT_ID : data.aws_caller_identity.current.account_id
      AWS_REGION : var.aws_region
      SERVER_DOMAIN : var.server_domain
      WEBHOOKS_ENDPOINT : "https://${var.server_domain}/webhooks"
      K8S_NAMESPACE : var.k8s_namespace

      # IAM
      SERVER_SERVICE_ACCOUNT_NAME : var.server_service_account_name
      SERVER_ROLE_ARN : module.iam.server_role_arn
      DRAIN_SERVICE_ACCOUNT_NAME : var.drain_service_account_name
      DRAIN_ROLE_ARN : module.iam.drain_role_arn
      SCHEDULER_SERVICE_ACCOUNT_NAME : var.scheduler_service_account_name
      SCHEDULER_ROLE_ARN : module.iam.scheduler_role_arn

      # Network
      # PUBLIC_IP_NAME : module.network.gke_public_v4_name,
      # PUBLIC_IP_ADDRESS : module.network.gke_public_v4_address,
      # PUBLIC_IPV6_NAME : module.network.gke_public_v6_name,
      # PUBLIC_IPV6_ADDRESS : module.network.gke_public_v6_address,
      # MQTT_IP_NAME : module.network.mqtt_v4_name,
      # MQTT_IP_ADDRESS : module.network.mqtt_v4_address,
      # MQTT_IPV6_NAME : module.network.mqtt_v6_name,
      # MQTT_IPV6_ADDRESS : module.network.mqtt_v6_address,
      # MQTT_BROKER_ENDPOINT : module.dns.mqtt_endpoint,
      MQTT_BROKER_ENDPOINT : "spacelift-mqtt.${var.k8s_namespace}.svc.cluster.local"
      # TODO(adamc): if we let folk bring their own VPC, maybe we add these as vars?
      SERVER_SECURITY_GROUP_ID : module.spacelift.server_security_group_id
      SERVER_LOAD_BALANCER_SECURITY_GROUP_ID = module.lb.load_balancer_security_group_id
      DRAIN_SECURITY_GROUP_ID : module.spacelift.drain_security_group_id
      SCHEDULER_SECURITY_GROUP_ID : module.spacelift.scheduler_security_group_id

      # Artifacts
      # ARTIFACT_REGISTRY_DOMAIN : module.artifacts.repository_domain,
      PRIVATE_ECR_LOGIN_URL : split("/", module.spacelift.ecr_backend_repository_url)[0]
      BACKEND_IMAGE : module.spacelift.ecr_backend_repository_url
      LAUNCHER_IMAGE : module.spacelift.ecr_launcher_repository_url
      BINARIES_BUCKET_NAME : module.spacelift.binaries_bucket_name

      # Buckets
      OBJECT_STORAGE_BUCKET_DELIVERIES               = module.spacelift.deliveries_bucket_name
      OBJECT_STORAGE_BUCKET_LARGE_QUEUE_MESSAGES     = module.spacelift.large_queue_messages_bucket_name
      OBJECT_STORAGE_BUCKET_MODULES                  = module.spacelift.modules_bucket_name
      OBJECT_STORAGE_BUCKET_POLICY_INPUTS            = module.spacelift.policy_inputs_bucket_name
      OBJECT_STORAGE_BUCKET_RUN_LOGS                 = module.spacelift.run_logs_bucket_name
      OBJECT_STORAGE_BUCKET_STATES                   = module.spacelift.states_bucket_name
      OBJECT_STORAGE_BUCKET_USER_UPLOADED_WORKSPACES = module.spacelift.user_uploaded_workspaces_bucket_name
      OBJECT_STORAGE_BUCKET_WORKSPACE                = module.spacelift.workspace_bucket_name
      OBJECT_STORAGE_BUCKET_METADATA                 = module.spacelift.metadata_bucket_name
      OBJECT_STORAGE_BUCKET_UPLOADS                  = module.spacelift.uploads_bucket_name
      OBJECT_STORAGE_BUCKET_UPLOADS_URL              = module.spacelift.uploads_bucket_url

      # Database
      DATABASE_URL           = module.spacelift.database_url
      DATABASE_READ_ONLY_URL = module.spacelift.database_read_only_url

      # Encryption
      # TODO(adamc): add the ability to choose between KMS and RSA.
      ENCRYPTION_TYPE                  = "kms"
      ENCRYPTION_KMS_ENCRYPTION_KEY_ID = module.spacelift.kms_encryption_key_arn
      ENCRYPTION_KMS_SIGNING_KEY_ID    = module.spacelift.kms_signing_key_arn

      # EKS
      EKS_CLUSTER_NAME = local.cluster_name
    },
  })
}

output "security_group_policies" {
  value = templatefile("${path.module}/security-group-policies.tftpl", {
    securityGroupIds = [
      module.spacelift.server_security_group_id,
      module.spacelift.drain_security_group_id,
      module.spacelift.scheduler_security_group_id
    ]
    namespace                     = var.k8s_namespace
    clusterPrimarySecurityGroupId = module.eks.cluster_primary_security_group_id
  })
}
