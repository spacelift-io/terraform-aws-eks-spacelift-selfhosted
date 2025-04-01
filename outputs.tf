output "shell" {
  sensitive   = true
  description = "Environment variables for installation tasks."
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
      MQTT_BROKER_DOMAIN : coalesce(var.mqtt_broker_domain, "spacelift-mqtt.${var.k8s_namespace}.svc.cluster.local")
      SERVER_SECURITY_GROUP_ID : local.server_security_group_id
      SERVER_LOAD_BALANCER_SECURITY_GROUP_ID = module.lb.load_balancer_security_group_id
      DRAIN_SECURITY_GROUP_ID : local.drain_security_group_id
      SCHEDULER_SECURITY_GROUP_ID : local.scheduler_security_group_id

      # Artifacts
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
      ENCRYPTION_TYPE                  = "kms"
      ENCRYPTION_KMS_ENCRYPTION_KEY_ID = module.spacelift.kms_encryption_key_arn
      ENCRYPTION_KMS_SIGNING_KEY_ID    = module.spacelift.kms_signing_key_arn

      # EKS
      EKS_CLUSTER_NAME = local.cluster_name
    },
  })
}

output "security_group_policies" {
  description = "Kubernetes security group policies for Spacelift. These K8s objects must be deployed to the cluster for the security groups to be used by the pods."
  value = templatefile("${path.module}/security-group-policies.tftpl", {
    securityGroupIds = [
      local.server_security_group_id,
      local.drain_security_group_id,
      local.scheduler_security_group_id
    ]
    namespace                     = var.k8s_namespace
    clusterPrimarySecurityGroupId = module.eks.cluster_primary_security_group_id
  })
}

output "unique_suffix" {
  value       = local.unique_suffix
  description = "Randomly generated suffix for AWS resource names, ensuring uniqueness."
}

output "eks_cluster_name" {
  value       = local.cluster_name
  description = "Name of the EKS cluster."
}

output "eks_cluster_primary_security_group_id" {
  value       = module.eks.cluster_primary_security_group_id
  description = "ID of the primary security group for the EKS cluster."
}

output "eks_cluster_arn" {
  value       = module.eks.cluster_arn
  description = "ARN of the EKS cluster."
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint of the EKS cluster."
}

output "eks_cluster_version" {
  value       = module.eks.cluster_version
  description = "Version of the EKS cluster."
}

output "eks_spacelift_namespace" {
  value       = var.k8s_namespace
  description = "Namespace for Spacelift in the EKS cluster."
}

output "eks_managed_node_groups" {
  value       = module.eks.eks_managed_node_groups
  description = "Map of attribute maps for all EKS managed node groups created."
}

output "eks_autoscaling_group_names" {
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
  description = "List of the autoscaling group names created by EKS managed node groups."
}

output "server_service_account_name" {
  value       = var.server_service_account_name
  description = "Name of the Kubernetes service account for the Spacelift server."
}

output "server_role_arn" {
  value       = module.iam.server_role_arn
  description = "ARN of the IAM role for the Spacelift server."
}

output "drain_role_arn" {
  value       = module.iam.drain_role_arn
  description = "ARN of the IAM role for the Spacelift drain."
}

output "drain_service_account_name" {
  value       = var.drain_service_account_name
  description = "Name of the Kubernetes service account for the Spacelift drain."
}

output "scheduler_service_account_name" {
  value       = var.scheduler_service_account_name
  description = "Name of the Kubernetes service account for the Spacelift scheduler."
}

output "scheduler_role_arn" {
  value       = module.iam.scheduler_role_arn
  description = "ARN of the IAM role for the Spacelift scheduler."
}

output "load_balancer_security_group_id" {
  value       = module.lb.load_balancer_security_group_id
  description = "ID of the security group for the load balancer."
}

output "mqtt_broker_domain" {
  value       = coalesce(var.mqtt_broker_domain, "spacelift-mqtt.${var.k8s_namespace}.svc.cluster.local")
  description = "Domain name of the MQTT broker."
}

output "kms_key_arn" {
  value       = coalesce(var.kms_arn, module.spacelift.kms_key_arn)
  description = "ARN of the KMS key used for encrypting AWS resources."
}

output "kms_encryption_key_arn" {
  value       = module.spacelift.kms_encryption_key_arn
  description = "ARN of the KMS key used for in-app encryption."
}

output "kms_signing_key_arn" {
  value       = module.spacelift.kms_signing_key_arn
  description = "ARN of the KMS key used for signing and verifying JWTs."
}

output "server_security_group_id" {
  value       = module.spacelift.server_security_group_id
  description = "ID of the security group for the Spacelift HTTP server."
}

output "drain_security_group_id" {
  value       = module.spacelift.drain_security_group_id
  description = "ID of the security group for the Spacelift async-processing service."
}

output "scheduler_security_group_id" {
  value       = module.spacelift.scheduler_security_group_id
  description = "ID of the security group for the Spacelift scheduler service."
}

output "database_security_group_id" {
  value       = var.create_vpc ? module.spacelift.database_security_group_id : null
  description = "ID of the security group for the Spacelift database. It will be null if create_database is false."
}

output "private_subnet_ids" {
  value       = var.create_vpc ? values(module.spacelift.private_subnet_ids) : null
  description = "IDs of the private subnets. They will be null if create_vpc is false."
}

output "public_subnet_ids" {
  value       = var.create_vpc ? values(module.spacelift.public_subnet_ids) : null
  description = "IDs of the public subnets. They will be null if create_vpc is false."
}

output "availability_zones" {
  value       = var.create_vpc ? keys(module.spacelift.private_subnet_ids) : null
  description = "Availability zones of the private subnets. They will be null if create_vpc is false."
}

output "vpc_id" {
  value       = var.create_vpc ? module.spacelift.vpc_id : null
  description = "ID of the VPC. It will be null if create_vpc is false."
}

output "rds_global_cluster_id" {
  description = "ID of the global Aurora cluster. Will be null if create_database is false."
  value       = var.create_database ? module.spacelift.rds_global_cluster_id : null
}

output "rds_cluster_endpoint" {
  description = "Endpoint of the RDS cluster. Will be null if create_database is false."
  value       = var.create_database ? module.spacelift.rds_cluster_endpoint : null
}

output "rds_cluster_reader_endpoint" {
  description = "Reader endpoint of the RDS cluster. Will be null if create_database is false."
  value       = var.create_database ? module.spacelift.rds_cluster_reader_endpoint : null
}

output "rds_username" {
  description = "Username for the RDS database."
  value       = module.spacelift.rds_username
}

output "rds_password" {
  description = "Password for the RDS database. Will be null if create_database is false."
  value       = var.create_database ? module.spacelift.rds_password : null
  sensitive   = true
}

output "database_url" {
  description = "The URL to the write endpoint of the database. Can be used to pass to the DATABASE_URL environment variable for Spacelift. Only populated if create_database is true."
  value       = module.spacelift.database_url
  sensitive   = true
}

output "database_read_only_url" {
  description = "The URL to the read endpoint of the database. Can be used to pass to the DATABASE_URL environment variable for Spacelift. Only populated if create_database is true."
  value       = module.spacelift.database_read_only_url
  sensitive   = true
}

output "ecr_backend_repository_url" {
  value       = module.spacelift.ecr_backend_repository_url
  description = "URL of the ECR repository for the backend images."
}

output "ecr_backend_repository_arn" {
  value       = module.spacelift.ecr_backend_repository_arn
  description = "ARN of the ECR repository for the backend images."
}

output "ecr_launcher_repository_url" {
  value       = module.spacelift.ecr_launcher_repository_url
  description = "URL of the ECR repository for the launcher images."
}

output "ecr_launcher_repository_arn" {
  value       = module.spacelift.ecr_launcher_repository_arn
  description = "ARN of the ECR repository for the launcher images."
}

output "binaries_bucket_arn" {
  value       = module.spacelift.binaries_bucket_arn
  description = "ARN of the S3 bucket used for storing binaries."
}

output "binaries_bucket_name" {
  value       = module.spacelift.binaries_bucket_name
  description = "ID of the S3 bucket used for storing binaries."
}

output "deliveries_bucket_arn" {
  value       = module.spacelift.deliveries_bucket_arn
  description = "ARN of the S3 bucket used for storing deliveries."
}

output "deliveries_bucket_name" {
  value       = module.spacelift.deliveries_bucket_name
  description = "ID of the S3 bucket used for storing deliveries."
}

output "large_queue_messages_bucket_arn" {
  value       = module.spacelift.large_queue_messages_bucket_arn
  description = "ARN of the S3 bucket used for storing large queue messages."
}

output "large_queue_messages_bucket_name" {
  value       = module.spacelift.large_queue_messages_bucket_name
  description = "ID of the S3 bucket used for storing large queue messages."
}

output "metadata_bucket_arn" {
  value       = module.spacelift.metadata_bucket_arn
  description = "ARN of the S3 bucket used for storing metadata."
}

output "metadata_bucket_name" {
  value       = module.spacelift.metadata_bucket_name
  description = "ID of the S3 bucket used for storing metadata."
}

output "modules_bucket_arn" {
  value       = module.spacelift.modules_bucket_arn
  description = "ARN of the S3 bucket used for storing modules."
}

output "modules_bucket_name" {
  value       = module.spacelift.modules_bucket_name
  description = "ID of the S3 bucket used for storing modules."
}

output "policy_inputs_bucket_arn" {
  value       = module.spacelift.policy_inputs_bucket_arn
  description = "ARN of the S3 bucket used for storing policy inputs."
}

output "policy_inputs_bucket_name" {
  value       = module.spacelift.policy_inputs_bucket_name
  description = "ID of the S3 bucket used for storing policy inputs."
}

output "run_logs_bucket_arn" {
  value       = module.spacelift.run_logs_bucket_arn
  description = "ARN of the S3 bucket used for storing run logs."
}

output "run_logs_bucket_name" {
  value       = module.spacelift.run_logs_bucket_name
  description = "ID of the S3 bucket used for storing run logs."
}

output "states_bucket_arn" {
  value       = module.spacelift.states_bucket_arn
  description = "ARN of the S3 bucket used for storing states."
}

output "states_bucket_name" {
  value       = module.spacelift.states_bucket_name
  description = "ID of the S3 bucket used for storing states."
}

output "uploads_bucket_arn" {
  value       = module.spacelift.uploads_bucket_arn
  description = "ARN of the S3 bucket used for storing uploads."
}

output "uploads_bucket_name" {
  value       = module.spacelift.uploads_bucket_name
  description = "ID of the S3 bucket used for storing uploads."
}

output "uploads_bucket_url" {
  value       = module.spacelift.uploads_bucket_url
  description = "URL of the S3 bucket used for storing uploads."
}

output "user_uploaded_workspaces_bucket_arn" {
  value       = module.spacelift.user_uploaded_workspaces_bucket_arn
  description = "ARN of the S3 bucket used for storing user uploaded workspaces."
}

output "user_uploaded_workspaces_bucket_name" {
  value       = module.spacelift.user_uploaded_workspaces_bucket_name
  description = "ID of the S3 bucket used for storing user uploaded workspaces."
}

output "workspace_bucket_arn" {
  value       = module.spacelift.workspace_bucket_arn
  description = "ARN of the S3 bucket used for storing workspaces."
}

output "workspace_bucket_name" {
  value       = module.spacelift.workspace_bucket_name
  description = "ID of the S3 bucket used for storing workspaces."
}
