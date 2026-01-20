variable "public_subnet_ids" {
  description = "List of public subnet IDs to use for the EKS cluster."
  type        = list(string)
  default     = []
}

variable "server_acm_arn" {
  type        = string
  description = "AWS Certificate Manager ARN for the server certificate. Only required for generating the helm_values output. It can be ignored if you are not using that output."
  default     = ""
}

variable "k8s_namespace" {
  type        = string
  description = "The namespace in which the Spacelift backend is deployed to"
  default     = "spacelift"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources."
}

variable "server_domain" {
  type        = string
  description = "The domain that Spacelift is being hosted on, for example spacelift.example.com."
}

variable "mqtt_broker_domain" {
  type        = string
  description = "The domain name to use for the MQTT broker (if enabling external workers). Leave unset if you only want to run workers in the same Kubernetes cluster that Spacelift runs in."
  default     = null
}

variable "kms_encryption_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encrypting data at rest."
}

variable "kms_signing_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for signing data."
}

variable "deliveries_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for deliveries."
}

variable "large_queue_messages_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for large queue messages."
}

variable "modules_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for modules."
}

variable "policy_inputs_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for policy inputs."
}

variable "run_logs_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for run logs."
}

variable "states_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for states."
}

variable "user_uploaded_workspaces_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for user uploaded workspaces."
}

variable "workspace_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for workspaces."
}

variable "metadata_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for metadata."
}

variable "uploads_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for uploads."
}

variable "uploads_bucket_url" {
  type        = string
  description = "The URL of the S3 bucket to use for uploads."
}

variable "database_url" {
  type        = string
  description = "The URL of the database to use for Spacelift. This is typically in the format 'postgresql://username:password@hostname:port/database'."
  sensitive   = true
}

variable "database_read_only_url" {
  type        = string
  description = "The read-only URL of the database to use for Spacelift. This is typically in the format 'postgresql://username:password@hostname:port/database'."
  sensitive   = true
}

variable "license_token" {
  type        = string
  description = "The JWT token for using Spacelift. Only required for generating the kubernetes_secrets output. It can be ignored if you are not using that output."
  default     = ""
  sensitive   = true
}

variable "spacelift_public_api" {
  type        = string
  description = "The public API to use when sending usage data. Only required for generating the kubernetes_secrets output. It can be ignored if you are not using that output."
  default     = ""
}

variable "ecr_launcher_repository_url" {
  type        = string
  description = "The URL of the ECR repository for the Spacelift launcher image."
}

variable "spacelift_version" {
  type        = string
  description = "The version of Spacelift being installed. Only required for generating the kubernetes_secrets output. It can be ignored if you are not using that output."
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "The username for the Spacelift admin account. Only required for generating the kubernetes_secrets output. It can be ignored if you are not using that output."
  default     = ""
}

variable "admin_password" {
  type        = string
  description = "The password for the Spacelift admin account. Only required for generating the kubernetes_secrets output. It can be ignored if you are not using that output."
  default     = ""
  sensitive   = true
}

variable "ecr_backend_repository_url" {
  type        = string
  description = "The URL of the ECR repository for the Spacelift backend image."
}

variable "server_service_account_name" {
  type        = string
  description = "The name of the Kubernetes service account to use for the server."
  default     = "spacelift-server"
}

variable "drain_service_account_name" {
  type        = string
  description = "The name of the Kubernetes service account to use for the drain."
  default     = "spacelift-drain"
}

variable "scheduler_service_account_name" {
  type        = string
  description = "The name of the Kubernetes service account to use for the scheduler."
  default     = "spacelift-scheduler"
}

variable "server_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the server service account."
}

variable "drain_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the drain service account."
}

variable "scheduler_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the scheduler service account."
}

variable "vcs_gateway_service_account_name" {
  type        = string
  description = "The name of the Kubernetes service account to use for the VCS gateway."
  default     = "spacelift-vcs-gateway"
}

variable "vcs_gateway_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the VCS gateway service account."
}

variable "vcs_gateway_domain" {
  type        = string
  description = "The domain for the VCS Gateway external endpoint (e.g., vcs-gateway.example.com). Required when using remote VCS agents."
  default     = null
}

variable "vcs_gateway_acm_arn" {
  type        = string
  description = "AWS Certificate Manager ARN for the VCS Gateway certificate."
  default     = ""
}

variable "create_sqs" {
  type        = bool
  description = "Whether to create the SQS queues for Spacelift."
  default     = false
}

variable "queue_urls" {
  type        = map(string)
  default     = null
  description = "A map of SQS queue names to urls. Only required if create_sqs is false."
}