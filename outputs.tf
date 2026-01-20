output "shell" {
  sensitive   = true
  description = "Environment variables for installation tasks. This output is just included as a convenience for use as part of the EKS getting started guide."
  value = templatefile("${path.module}/env.tftpl", {
    env : {
      AWS_ACCOUNT_ID    = data.aws_caller_identity.current.account_id
      AWS_REGION        = var.aws_region
      SERVER_DOMAIN     = var.server_domain
      SPACELIFT_VERSION = var.spacelift_version != null ? var.spacelift_version : ""

      # Artifacts
      PRIVATE_ECR_LOGIN_URL = split("/", module.spacelift.ecr_backend_repository_url)[0]
      BACKEND_IMAGE         = module.spacelift.ecr_backend_repository_url
      LAUNCHER_IMAGE        = module.spacelift.ecr_launcher_repository_url
      BINARIES_BUCKET_NAME  = module.spacelift.binaries_bucket_name

      # EKS
      EKS_CLUSTER_NAME = local.cluster_name
      K8S_NAMESPACE    = var.k8s_namespace
    },
  })
}

output "kubernetes_ingress_class" {
  description = "Generates an IngressClassParameters and IngressClass resource to configure the server load balancer. This output is just included as a convenience for use as part of the EKS getting started guide."
  value       = module.kube_outputs.kubernetes_ingress_class
}

output "kubernetes_secrets" {
  sensitive   = true
  description = "Kubernetes secrets required for the Spacelift services. This output is just included as a convenience for use as part of the EKS getting started guide."
  value       = module.kube_outputs.kubernetes_secrets
}

output "helm_values" {
  description = "Generates a Helm values.yaml file that can be used when deploying Spacelift. This output is just included as a convenience for use as part of the EKS getting started guide."
  value       = module.kube_outputs.helm_values
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

output "vcs_gateway_service_account_name" {
  value       = var.vcs_gateway_service_account_name
  description = "Name of the Kubernetes service account for the Spacelift VCS gateway."
}

output "vcs_gateway_role_arn" {
  value       = module.iam.vcs_gateway_role_arn
  description = "ARN of the IAM role for the Spacelift VCS gateway."
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

output "database_security_group_id" {
  value       = var.create_vpc ? module.spacelift.database_security_group_id : null
  description = "ID of the security group for the Spacelift database. It will be null if create_database is false."
}

output "private_subnet_ids" {
  value       = local.private_subnet_ids
  description = "IDs of the private subnets. They will be null if create_vpc is false."
}

output "public_subnet_ids" {
  value       = local.public_subnet_ids
  description = "IDs of the public subnets. They will be null if create_vpc is false."
}

output "availability_zones" {
  value       = var.create_vpc ? module.spacelift.availability_zones : null
  description = "Availability zones of the private subnets. They will be null if create_vpc is false."
}

output "vpc_id" {
  value       = local.vpc_id
  description = "ID of the VPC. It will be null if create_vpc is false."
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

output "ebs_kms_key_arn" {
  value       = local.create_ebs_key ? aws_kms_key.ebs[0].arn : var.ebs_encryption.kms_key_arn
  description = "ARN of the KMS key used for EBS volume encryption. Only set when account_enforces_ebs_encryption is true."
}

output "ebs_kms_key_id" {
  value       = local.create_ebs_key ? aws_kms_key.ebs[0].key_id : null
  description = "ID of the KMS key used for EBS volume encryption. Only set when account_enforces_ebs_encryption is true."
}

output "ebs_encrypted_volumes_patch" {
  value       = var.ebs_encryption.enabled ? "kubectl patch nodeclass default --type=merge -p '{\"spec\":{\"ephemeralStorage\":{\"kmsKeyID\":\"${local.ebs_kms_key_arn}\"}}}'" : "echo \"account_enforces_ebs_encryption is not enabled\""
  description = "kubectl command to patch the default NodeClass with the EBS KMS key. Execute with: $(tofu output -raw ebs_encrypted_volumes_patch)"
}
