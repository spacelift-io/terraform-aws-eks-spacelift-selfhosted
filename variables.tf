### General

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources."
}

variable "unique_suffix" {
  type        = string
  description = "A unique suffix to append to resource names. If not provided, one will be generated."
  default     = null
}

variable "server_domain" {
  type        = string
  description = "The domain that Spacelift is being hosted on, for example spacelift.example.com."
}

variable "license_token" {
  type        = string
  description = "The JWT token for using Spacelift. Only required for generating the kubernetes_secrets output. It can be ignored if you are not using that output."
  default     = ""
  sensitive   = true
}

### KMS

variable "kms_arn" {
  type        = string
  description = "ARN of the KMS key to use for encryption: S3 buckets, RDS instances, and ECR repositories. If empty, a new KMS key will be created."
  default     = null
}

variable "encryption_type" {
  type        = string
  description = "The encryption type to use. Can be 'kms' or 'rsa'."
  default     = "kms"

  validation {
    condition     = contains(["kms", "rsa"], var.encryption_type)
    error_message = "encryption_type must be one of 'kms' or 'rsa'"
  }
}

variable "kms_encryption_key_arn" {
  type        = string
  description = "ARN of an externally-managed KMS key for in-app encryption. When null, uses the key created by the upstream spacelift module."
  default     = null
}

variable "kms_signing_key_arn" {
  type        = string
  description = "ARN of an externally-managed KMS key for signing and verifying JWTs. When null, uses the key created by the upstream spacelift module."
  default     = null
}

variable "kms_master_key_multi_regional" {
  type        = bool
  description = "Whether the KMS master key should be multi-regional."
  default     = null
}

variable "kms_jwt_key_multi_regional" {
  type        = bool
  description = "Whether the JWT key should be multi-regional."
  default     = null
}

### VPC & Networking

variable "create_vpc" {
  type        = bool
  description = "Whether to create a VPC for the Spacelift resources. Default is true. Note: if this is false, and create_database is true, you must provide rds_subnet_ids and rds_security_group_ids."
  default     = true
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block to use for the VPC created for Spacelift. The subnet mask must be between /16 and /24."
  default     = "10.0.0.0/18"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to use if create_vpc is false."
  default     = null
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for the public subnets. Only used when create_vpc is true."
  default     = []
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for the private subnets. Only used when create_vpc is true."
  default     = []
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs to use for the EKS cluster. If create_vpc is false, this must be provided."
  default     = []
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs to use for the RDS instances and EKS cluster. If create_vpc is false, this must be provided."
  default     = []
}

variable "availability_zones" {
  type        = list(string)
  description = "overriding aws availability zones"
  default     = null
}

variable "security_group_names" {
  type = object({
    database    = string
    server      = string
    drain       = string
    scheduler   = string
    vcs_gateway = string
  })
  description = "Custom names for the security groups to create."
  default     = null
}

### RDS / Database

variable "create_database" {
  type        = bool
  description = "Whether to create the Aurora RDS database. Default is true."
  default     = true
}

variable "rds_engine_version" {
  type        = string
  description = "Postgres engine version."
}

variable "rds_engine_mode" {
  type        = string
  description = "Engine mode for the RDS instances. Default is 'provisioned'. Can be either 'serverless' or 'provisioned'."
  default     = "provisioned"

  validation {
    condition     = var.rds_engine_mode == "serverless" || var.rds_engine_mode == "provisioned"
    error_message = "Engine mode must be either 'serverless' or 'provisioned'."
  }
}

variable "rds_username" {
  type        = string
  description = "Master username for the RDS instances. Note: this won't be used by the application, but it's required by the RDS resource."
  default     = "spacelift"
}

variable "rds_instance_configuration" {
  type = map(object({
    instance_identifier = string
    instance_class      = string
  }))
  description = "Instance configuration for the RDS instances. Default is a single db.r6g.large instance."
  default = {
    "primary-instance" = {
      instance_identifier = "primary"
      instance_class      = "db.serverless"
    }
  }
}

variable "rds_serverlessv2_scaling_configuration" {
  type = object({
    max_capacity : number
    min_capacity : number
    seconds_until_auto_pause : optional(number)
  })
  description = "The serverlessv2_scaling_configuration block to use for the RDS cluster"
  default = {
    min_capacity = 0.5
    max_capacity = 5.0
  }
}

variable "rds_regional_cluster_identifier" {
  type        = string
  description = "The identifier for the RDS cluster. If not provided, a name will be generated."
  default     = null
}

variable "rds_parameter_group_name" {
  type        = string
  description = "Name of the RDS parameter group."
  default     = null
}

variable "rds_parameter_group_description" {
  type        = string
  description = "Description of the RDS parameter group."
  default     = null
}

variable "rds_subnet_group_name" {
  type        = string
  description = "Name of the RDS subnet group. If not provided, a name will be generated."
  default     = null
}

variable "rds_password_sm_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret storing the DB cluster password. Only used when importing an existing database."
  default     = null
}

variable "rds_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to use for the RDS instances. If create_vpc is false, this must be provided."
  default     = []
}

variable "rds_delete_protection_enabled" {
  type        = bool
  description = "Whether to enable deletion protection for the RDS instances."
  default     = true
}

variable "rds_preferred_backup_window" {
  type        = string
  description = "Daily time range during which automated backups are created if automated backups are enabled using the rds_backup_retention_period parameter."
  default     = "07:00-09:00"
}

variable "rds_backup_retention_period" {
  type        = number
  description = "The number of days for which automated backups are retained. Default is 3."
  default     = 3
}

variable "rds_apply_immediately" {
  type        = bool
  description = "Whether to apply RDS changes immediately or during the next maintenance window."
  default     = true
}

### S3

variable "s3_bucket_configuration" {
  type = object({
    binaries     = object({ name = string, expiration_days = number })
    deliveries   = object({ name = string, expiration_days = number })
    large_queue  = object({ name = string, expiration_days = number })
    metadata     = object({ name = string, expiration_days = number })
    modules      = object({ name = string, expiration_days = number })
    policy       = object({ name = string, expiration_days = number })
    run_logs     = object({ name = string, expiration_days = number })
    states       = object({ name = string, expiration_days = number })
    uploads      = object({ name = string, expiration_days = number })
    user_uploads = object({ name = string, expiration_days = number })
    workspace    = object({ name = string, expiration_days = number })
  })
  description = "Custom configuration for S3 buckets. When null, bucket names are auto-generated."
  default     = null
}

variable "s3_retain_on_destroy" {
  type        = bool
  description = "Whether to retain the S3 buckets' contents when destroyed. If true, and the S3 bucket isn't empty, the deletion will fail."
  default     = true
}

variable "enable_public_access_block_on_s3" {
  type        = bool
  description = "Whether to enable the public access block on the bucket."
  default     = true
}

### SQS

variable "create_sqs" {
  type        = bool
  description = "Whether to create the SQS queues for Spacelift."
  default     = false
}

variable "sqs_queue_names_override" {
  type        = map(string)
  description = "Map of SQS queue URLs/names to use when providing externally-managed queues (create_sqs = false). Expected keys: deadletter, deadletter_fifo, async_jobs, events_inbox, async_jobs_fifo, cronjobs, webhooks, iot."
  default     = null
}

### ECR

variable "backend_ecr_repository_name" {
  type        = string
  description = "Name of the backend ECR repository."
  default     = null
}

variable "launcher_ecr_repository_name" {
  type        = string
  description = "Name of the launcher ECR repository."
  default     = null
}

variable "number_of_images_to_retain" {
  type        = number
  description = "Number of Docker images to retain in ECR repositories. Default is 5. If set to 0, no images will be cleaned up."
  default     = 5
}

variable "ecr_force_delete" {
  type        = bool
  description = "Whether to force delete the ECRs, even if they contain images."
  default     = false
}

### EKS

variable "eks_cluster_name" {
  description = "A custom name to use for the EKS cluster. By default one will be generated for you."
  default     = null
}

variable "eks_auto_mode_enabled" {
  type        = bool
  description = "Whether to enable EKS Auto Mode."
  default     = true
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type = map(object({
    create             = optional(bool)
    kubernetes_version = optional(string)

    # EKS Managed Node Group
    name                           = optional(string) # Will fall back to map key
    use_name_prefix                = optional(bool)
    subnet_ids                     = optional(list(string))
    min_size                       = optional(number)
    max_size                       = optional(number)
    desired_size                   = optional(number)
    ami_id                         = optional(string)
    ami_type                       = optional(string)
    ami_release_version            = optional(string)
    use_latest_ami_release_version = optional(bool)
    capacity_type                  = optional(string)
    disk_size                      = optional(number)
    force_update_version           = optional(bool)
    instance_types                 = optional(list(string))
    labels                         = optional(map(string))
    node_repair_config = optional(object({
      enabled                                 = optional(bool)
      max_parallel_nodes_repaired_count       = optional(number)
      max_parallel_nodes_repaired_percentage  = optional(number)
      max_unhealthy_node_threshold_count      = optional(number)
      max_unhealthy_node_threshold_percentage = optional(number)
      node_repair_config_overrides = optional(list(object({
        min_repair_wait_time_mins = number
        node_monitoring_condition = string
        node_unhealthy_reason     = string
        repair_action             = string
      })))
    }))
    remote_access = optional(object({
      ec2_ssh_key               = optional(string)
      source_security_group_ids = optional(list(string))
    }))
    taints = optional(map(object({
      key    = string
      value  = optional(string)
      effect = string
    })))
    update_config = optional(object({
      max_unavailable            = optional(number)
      max_unavailable_percentage = optional(number)
      update_strategy            = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    # User data
    enable_bootstrap_user_data = optional(bool)
    pre_bootstrap_user_data    = optional(string)
    post_bootstrap_user_data   = optional(string)
    bootstrap_extra_args       = optional(string)
    user_data_template_path    = optional(string)
    cloudinit_pre_nodeadm = optional(list(object({
      content      = string
      content_type = optional(string)
      filename     = optional(string)
      merge_type   = optional(string)
    })))
    cloudinit_post_nodeadm = optional(list(object({
      content      = string
      content_type = optional(string)
      filename     = optional(string)
      merge_type   = optional(string)
    })))
    # Launch Template
    create_launch_template                 = optional(bool)
    use_custom_launch_template             = optional(bool)
    launch_template_id                     = optional(string)
    launch_template_name                   = optional(string) # Will fall back to map key
    launch_template_use_name_prefix        = optional(bool)
    launch_template_version                = optional(string)
    launch_template_default_version        = optional(string)
    update_launch_template_default_version = optional(bool)
    launch_template_description            = optional(string)
    launch_template_tags                   = optional(map(string))
    tag_specifications                     = optional(list(string))
    ebs_optimized                          = optional(bool)
    key_name                               = optional(string)
    disable_api_termination                = optional(bool)
    kernel_id                              = optional(string)
    ram_disk_id                            = optional(string)
    block_device_mappings = optional(map(object({
      device_name = optional(string)
      ebs = optional(object({
        delete_on_termination      = optional(bool)
        encrypted                  = optional(bool)
        iops                       = optional(number)
        kms_key_id                 = optional(string)
        snapshot_id                = optional(string)
        throughput                 = optional(number)
        volume_initialization_rate = optional(number)
        volume_size                = optional(number)
        volume_type                = optional(string)
      }))
      no_device    = optional(string)
      virtual_name = optional(string)
    })))
    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string)
      capacity_reservation_target = optional(object({
        capacity_reservation_id                 = optional(string)
        capacity_reservation_resource_group_arn = optional(string)
      }))
    }))
    cpu_options = optional(object({
      amd_sev_snp      = optional(string)
      core_count       = optional(number)
      threads_per_core = optional(number)
    }))
    credit_specification = optional(object({
      cpu_credits = optional(string)
    }))
    enclave_options = optional(object({
      enabled = optional(bool)
    }))
    instance_market_options = optional(object({
      market_type = optional(string)
      spot_options = optional(object({
        block_duration_minutes         = optional(number)
        instance_interruption_behavior = optional(string)
        max_price                      = optional(string)
        spot_instance_type             = optional(string)
        valid_until                    = optional(string)
      }))
    }))
    license_specifications = optional(list(object({
      license_configuration_arn = string
    })))
    metadata_options = optional(object({
      http_endpoint               = optional(string)
      http_protocol_ipv6          = optional(string)
      http_put_response_hop_limit = optional(number)
      http_tokens                 = optional(string)
      instance_metadata_tags      = optional(string)
    }))
    enable_monitoring      = optional(bool)
    enable_efa_support     = optional(bool)
    enable_efa_only        = optional(bool)
    efa_indices            = optional(list(string))
    create_placement_group = optional(bool)
    placement = optional(object({
      affinity                = optional(string)
      availability_zone       = optional(string)
      group_name              = optional(string)
      host_id                 = optional(string)
      host_resource_group_arn = optional(string)
      partition_number        = optional(number)
      spread_domain           = optional(string)
      tenancy                 = optional(string)
    }))
    network_interfaces = optional(list(object({
      associate_carrier_ip_address = optional(bool)
      associate_public_ip_address  = optional(bool)
      connection_tracking_specification = optional(object({
        tcp_established_timeout = optional(number)
        udp_stream_timeout      = optional(number)
        udp_timeout             = optional(number)
      }))
      delete_on_termination = optional(bool)
      description           = optional(string)
      device_index          = optional(number)
      ena_srd_specification = optional(object({
        ena_srd_enabled = optional(bool)
        ena_srd_udp_specification = optional(object({
          ena_srd_udp_enabled = optional(bool)
        }))
      }))
      interface_type       = optional(string)
      ipv4_address_count   = optional(number)
      ipv4_addresses       = optional(list(string))
      ipv4_prefix_count    = optional(number)
      ipv4_prefixes        = optional(list(string))
      ipv6_address_count   = optional(number)
      ipv6_addresses       = optional(list(string))
      ipv6_prefix_count    = optional(number)
      ipv6_prefixes        = optional(list(string))
      network_card_index   = optional(number)
      network_interface_id = optional(string)
      primary_ipv6         = optional(bool)
      private_ip_address   = optional(string)
      security_groups      = optional(list(string), [])
      subnet_id            = optional(string)
    })))
    maintenance_options = optional(object({
      auto_recovery = optional(string)
    }))
    private_dns_name_options = optional(object({
      enable_resource_name_dns_aaaa_record = optional(bool)
      enable_resource_name_dns_a_record    = optional(bool)
      hostname_type                        = optional(string)
    }))
    # IAM role
    create_iam_role               = optional(bool)
    iam_role_arn                  = optional(string)
    iam_role_name                 = optional(string)
    iam_role_use_name_prefix      = optional(bool)
    iam_role_path                 = optional(string)
    iam_role_description          = optional(string)
    iam_role_permissions_boundary = optional(string)
    iam_role_tags                 = optional(map(string))
    iam_role_attach_cni_policy    = optional(bool)
    iam_role_additional_policies  = optional(map(string))
    create_iam_role_policy        = optional(bool)
    iam_role_policy_statements = optional(list(object({
      sid           = optional(string)
      actions       = optional(list(string))
      not_actions   = optional(list(string))
      effect        = optional(string)
      resources     = optional(list(string))
      not_resources = optional(list(string))
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      not_principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      condition = optional(list(object({
        test     = string
        values   = list(string)
        variable = string
      })))
    })))
    # Security group
    vpc_security_group_ids                = optional(list(string), [])
    attach_cluster_primary_security_group = optional(bool, false)
    cluster_primary_security_group_id     = optional(string)
    create_security_group                 = optional(bool)
    security_group_name                   = optional(string)
    security_group_use_name_prefix        = optional(bool)
    security_group_description            = optional(string)
    security_group_ingress_rules = optional(map(object({
      name                         = optional(string)
      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      description                  = optional(string)
      from_port                    = optional(string)
      ip_protocol                  = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)
      self                         = optional(bool)
      tags                         = optional(map(string))
      to_port                      = optional(string)
    })))
    security_group_egress_rules = optional(map(object({
      name                         = optional(string)
      cidr_ipv4                    = optional(string)
      cidr_ipv6                    = optional(string)
      description                  = optional(string)
      from_port                    = optional(string)
      ip_protocol                  = optional(string)
      prefix_list_id               = optional(string)
      referenced_security_group_id = optional(string)
      self                         = optional(bool)
      tags                         = optional(map(string))
      to_port                      = optional(string)
    })), {})
    security_group_tags = optional(map(string))

    tags = optional(map(string))
  }))
  default = null
}

variable "eks_cluster_version" {
  type        = string
  description = "The Kubernetes version to run on the cluster. If not specified, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS."
  default     = null
}

variable "eks_upgrade_policy" {
  type = object({
    support_type = string
  })
  description = "EKS cluster upgrade policy. support_type can be 'STANDARD' (14 months) or 'EXTENDED' (26 months). Extended support provides 12 additional months for planning upgrades but incurs additional costs. Clusters are automatically upgraded at the end of the support period."
  default     = null
}

variable "ebs_encryption" {
  type = object({
    enabled : bool,
    kms_key_arn : optional(string)
  })
  description = "Whether the AWS account enforces EBS encryption by default. If true, a separate KMS key will be created for node EBS volumes with the appropriate permissions for EKS Auto Mode. See https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3037 for more information."
  default = {
    enabled = false
  }
}

### MQTT

variable "mqtt_broker_domain" {
  type        = string
  description = "The domain name (without protocol) to use for the MQTT broker (if enabling external workers). Leave unset if you only want to run workers in the same Kubernetes cluster that Spacelift runs in. Example: mqtt-broker.mycorp.com."
  default     = null
}

variable "mqtt_broker_type" {
  type        = string
  description = "The type of MQTT broker to use. Can be 'builtin' for the embedded MQTT server, or 'iotcore' for AWS IoT Core."
  default     = "builtin"

  validation {
    condition     = contains(["builtin", "iotcore"], var.mqtt_broker_type)
    error_message = "mqtt_broker_type must be either 'builtin' or 'iotcore'."
  }
}

variable "mqtt_broker_endpoint" {
  type        = string
  description = "Override for the MQTT broker endpoint. When not set, defaults to tls://<mqtt_broker_domain>:1984."
  default     = null
}

### Kubernetes & Helm outputs

variable "k8s_namespace" {
  type        = string
  description = "The namespace in which the Spacelift backend is deployed to"
  default     = "spacelift"
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

variable "vcs_gateway_service_account_name" {
  type        = string
  description = "The name of the Kubernetes service account to use for the VCS gateway."
  default     = "spacelift-vcs-gateway"
}

variable "spacelift_public_api" {
  type        = string
  description = "The public API to use when sending usage data. Only required for generating the kubernetes_secrets output. It can be ignored if you are not using that output."
  default     = ""
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

variable "server_acm_arn" {
  type        = string
  description = "AWS Certificate Manager ARN for the server certificate. Only required for generating the kubernetes_secrets and helm_values outputs. It can be ignored if you are not using those outputs."
  default     = ""
}

### VCS Gateway

variable "vcs_gateway_domain" {
  type        = string
  description = "The domain for the VCS Gateway external endpoint (e.g., vcs-gateway.example.com). Required when using remote VCS agents."
  default     = null
}

variable "vcs_gateway_acm_arn" {
  type        = string
  description = "AWS Certificate Manager ARN for the VCS Gateway certificate. Only required for generating the kubernetes_secrets and helm_values outputs. It can be ignored if you are not using those outputs."
  default     = ""
}
