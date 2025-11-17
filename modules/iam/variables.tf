variable "unique_suffix" {
  type        = string
  description = "The suffix to add to resource names to make them unique."
}

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID containing the Kubernetes cluster."
}

variable "aws_partition" {
  type        = string
  description = "The AWS partition the services are being run in."
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key used for encrypting AWS resources (ECR, S3, etc.)."
}

variable "kms_encryption_key_arn" {
  type        = string
  description = "The KMS encryption key ID to use for encryption. Required if encryption_type is 'kms'."
}

variable "kms_signing_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for signing JWT tokens. Required if encryption_type is 'kms'."
}

variable "deliveries_bucket_name" {
  type        = string
  description = "The name of the deliveries S3 bucket."
}

variable "large_queue_messages_bucket_name" {
  type        = string
  description = "The name of the large queue messages S3 bucket."
}

variable "modules_bucket_name" {
  type        = string
  description = "The name of the modules S3 bucket."
}

variable "policy_inputs_bucket_name" {
  type        = string
  description = "The name of the policy inputs S3 bucket."
}

variable "run_logs_bucket_name" {
  type        = string
  description = "The name of the run logs S3 bucket."
}

variable "metadata_bucket_name" {
  type        = string
  description = "The name of the metadata S3 bucket."
}

variable "states_bucket_name" {
  type        = string
  description = "The name of the states S3 bucket."
}

variable "user_uploaded_workspaces_bucket_name" {
  type        = string
  description = "The name of the user uploaded workspaces S3 bucket."
}

variable "workspace_bucket_name" {
  type        = string
  description = "The name of the workspace S3 bucket."
}

variable "uploads_bucket_name" {
  type        = string
  description = "The name of the uploads S3 bucket."
}

variable "oidc_provider" {
  type        = string
  description = "The EKS OIDC provider."
}

variable "namespace" {
  type        = string
  description = "The Kubernetes namespace Spacelift is being installed into."
}

variable "server_service_account_name" {
  type        = string
  description = "The name of the Kubernetes service account used by the server."
}

variable "drain_service_account_name" {
  type        = string
  description = "The name of the Kubernetes service account used by the server."
}

variable "scheduler_service_account_name" {
  type        = string
  description = "The name of the Kubernetes service account used by the server."
}

variable "create_sqs" {
  type        = bool
  description = "Whether to create the SQS queues for Spacelift."
  default     = false
}

variable "queue_arns" {
  type        = map(string)
  default     = null
  description = "A map of SQS queue names to arns. Only required if create_sqs is false."
}