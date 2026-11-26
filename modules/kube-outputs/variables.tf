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

variable "mqtt_broker_type" {
  type        = string
  description = "The type of MQTT broker to use. Can be 'builtin' or 'iotcore'."
  default     = "builtin"
}

variable "mqtt_broker_endpoint" {
  type        = string
  description = "Override for the MQTT broker endpoint. When not set, defaults to tls://<mqtt_broker_domain>:1984."
  default     = null
}

variable "encryption_type" {
  type        = string
  description = "The encryption type to use. Can be 'kms' or 'rsa'."
  default     = "kms"
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

variable "run_observability_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to use for run observability artifacts."
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

variable "database_iam_auth" {
  type        = bool
  description = "Whether the backend should authenticate to the database with AWS RDS IAM tokens instead of the password in the connection string."
  default     = false
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
  description = "The repository URL of the Spacelift launcher image, without a tag. If null, the kubernetes_secrets output leaves out LAUNCHER_IMAGE and LAUNCHER_IMAGE_TAG, and you set the launcher image in your Helm values instead."
  default     = null
}

variable "spacelift_version" {
  type        = string
  description = "The version of Spacelift being installed. Only required for generating the kubernetes_secrets output. It can be ignored if you are not using that output."
  default     = ""
}

variable "drain_concurrency_async_jobs" {
  type        = number
  description = "Number of concurrent receivers for the async-jobs queue per drain pod."
  default     = 1
}

variable "drain_concurrency_async_jobs_fifo" {
  type        = number
  description = "Number of concurrent receivers for the async-jobs.fifo queue per drain pod."
  default     = 1
}

variable "drain_concurrency_cronjobs" {
  type        = number
  description = "Number of concurrent receivers for the cronjobs queue per drain pod."
  default     = 1
}

variable "drain_concurrency_dlq" {
  type        = number
  description = "Number of concurrent receivers for the DLQ queue per drain pod."
  default     = 1
}

variable "drain_concurrency_dlq_fifo" {
  type        = number
  description = "Number of concurrent receivers for the DLQ FIFO queue per drain pod."
  default     = 1
}

variable "drain_concurrency_events" {
  type        = number
  description = "Number of concurrent receivers for the events-inbox queue per drain pod."
  default     = 1
}

variable "drain_concurrency_iot" {
  type        = number
  description = "Number of concurrent receivers for the IoT queue per drain pod."
  default     = 1
}

variable "drain_concurrency_webhooks" {
  type        = number
  description = "Number of concurrent receivers for the webhooks queue per drain pod."
  default     = 1
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
  description = "The repository URL of the Spacelift backend image, without a tag. If null, the helm_values output leaves out shared.image: it then pulls the images from oci.spacelift.io when spacelift_registry_pull_secret_name is set, otherwise you set the images in your Helm values yourself."
  default     = null
}

variable "spacelift_registry_pull_secret_name" {
  type        = string
  description = "Name of the Kubernetes secret holding your credentials for oci.spacelift.io. Set this to pull both the backend and launcher images from the Spacelift registry: the helm_values output then references this secret and enables the chart's launcher image, and no longer sets an image from the module's ECR repositories. You create the secret yourself, in the namespace you install Spacelift to. Launcher pull credentials for worker pools are not covered by this secret, set them on the worker pool controller as well."
  default     = null

  validation {
    condition     = var.spacelift_registry_pull_secret_name != ""
    error_message = "spacelift_registry_pull_secret_name must not be empty."
  }
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

variable "server_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the server service account."
}

variable "drain_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for the drain service account."
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

variable "sqs_queue_urls_generated" {
  type        = map(string)
  default     = null
  description = "Map of SQS queue URLs generated by the upstream spacelift module."
}

variable "sqs_queue_names_override" {
  type        = map(string)
  description = "Map of user-provided SQS queue names for externally-managed queues. Takes priority over sqs_queue_urls_generated."
  default     = null
}

variable "flows" {
  type = object({
    domain               = string
    acm_arn              = string
    expose_gateway       = bool
    service_account_name = string
    role_arn             = string
    bucket_name          = string
    ecr_repository_url   = string
    organization_name    = string
    admin_email          = string
    agent_pool_id        = string
  })
  description = "Spacelift Flows settings. Null when Flows is not deployed, and then the outputs contain nothing about Flows."
  default     = null
}

variable "flows_secrets" {
  type = object({
    database_url     = string
    admin_password   = string
    agent_pool_token = string
    extra_config     = any
  })
  description = "The sensitive part of the Spacelift Flows settings. Null when Flows is not deployed."
  sensitive   = true
  default     = null
}
