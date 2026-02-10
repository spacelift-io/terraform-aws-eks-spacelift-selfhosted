data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_iot_endpoint" "iot" {
  count         = var.mqtt_broker_type == "iotcore" ? 1 : 0
  endpoint_type = "iot:Data-ATS"
}

resource "random_uuid" "suffix" {
}

locals {
  unique_suffix = coalesce(var.unique_suffix, lower(substr(random_uuid.suffix.id, 0, 5)))
  cluster_name  = coalesce(var.eks_cluster_name, "spacelift-cluster-${module.spacelift.unique_suffix}")

  vpc_id             = var.create_vpc ? module.spacelift.vpc_id : var.vpc_id
  private_subnet_ids = var.create_vpc ? module.spacelift.private_subnet_ids : var.private_subnet_ids
  public_subnet_ids  = var.create_vpc ? module.spacelift.public_subnet_ids : var.public_subnet_ids

  mqtt_broker_endpoint = coalesce(
    var.mqtt_broker_endpoint,
    var.mqtt_broker_type == "iotcore"
    ? data.aws_iot_endpoint.iot[0].endpoint_address
    : "tls://${coalesce(var.mqtt_broker_domain, "spacelift-mqtt.${var.k8s_namespace}.svc.cluster.local")}:1984"
  )

  sqs_queue_arns_from_override = var.sqs_queue_names_override != null ? {
    for k, v in var.sqs_queue_names_override :
    k => "arn:${data.aws_partition.current.partition}:sqs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${v}"
  } : null
}

module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-selfhosted?ref=v2.1.1"

  unique_suffix    = local.unique_suffix
  region           = var.aws_region
  website_endpoint = "https://${var.server_domain}"

  kms_arn                       = var.kms_arn
  kms_master_key_multi_regional = var.kms_master_key_multi_regional
  kms_jwt_key_multi_regional    = var.kms_jwt_key_multi_regional

  create_vpc                 = var.create_vpc
  vpc_cidr_block             = var.vpc_cidr_block
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  enable_dns_hostnames       = true
  availability_zones         = var.availability_zones
  security_group_names       = var.security_group_names

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  create_database                        = var.create_database
  rds_subnet_ids                         = var.private_subnet_ids
  rds_security_group_ids                 = var.rds_security_group_ids
  rds_serverlessv2_scaling_configuration = var.rds_serverlessv2_scaling_configuration
  rds_regional_cluster_identifier        = var.rds_regional_cluster_identifier
  rds_parameter_group_name               = var.rds_parameter_group_name
  rds_parameter_group_description        = var.rds_parameter_group_description
  rds_subnet_group_name                  = var.rds_subnet_group_name
  rds_password_sm_arn                    = var.rds_password_sm_arn
  rds_delete_protection_enabled          = var.rds_delete_protection_enabled
  rds_engine_version                     = var.rds_engine_version
  rds_engine_mode                        = var.rds_engine_mode
  rds_username                           = var.rds_username
  rds_instance_configuration             = var.rds_instance_configuration
  rds_preferred_backup_window            = var.rds_preferred_backup_window
  rds_backup_retention_period            = var.rds_backup_retention_period
  rds_apply_immediately                  = var.rds_apply_immediately

  s3_bucket_configuration          = var.s3_bucket_configuration
  s3_retain_on_destroy             = var.s3_retain_on_destroy
  enable_public_access_block_on_s3 = var.enable_public_access_block_on_s3

  create_sqs = var.create_sqs

  backend_ecr_repository_name  = var.backend_ecr_repository_name
  launcher_ecr_repository_name = var.launcher_ecr_repository_name
  number_of_images_to_retain   = var.number_of_images_to_retain
  ecr_force_delete             = var.ecr_force_delete
}

module "iam" {
  source = "./modules/iam"

  unique_suffix  = module.spacelift.unique_suffix
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_partition  = data.aws_partition.current.partition

  # KMS
  kms_key_arn            = module.spacelift.kms_key_arn
  kms_encryption_key_arn = coalesce(var.kms_encryption_key_arn, module.spacelift.kms_encryption_key_arn)
  kms_signing_key_arn    = coalesce(var.kms_signing_key_arn, module.spacelift.kms_signing_key_arn)

  # S3
  deliveries_bucket_name               = module.spacelift.deliveries_bucket_name
  large_queue_messages_bucket_name     = module.spacelift.large_queue_messages_bucket_name
  metadata_bucket_name                 = module.spacelift.metadata_bucket_name
  modules_bucket_name                  = module.spacelift.modules_bucket_name
  policy_inputs_bucket_name            = module.spacelift.policy_inputs_bucket_name
  run_logs_bucket_name                 = module.spacelift.run_logs_bucket_name
  states_bucket_name                   = module.spacelift.states_bucket_name
  uploads_bucket_name                  = module.spacelift.uploads_bucket_name
  user_uploaded_workspaces_bucket_name = module.spacelift.user_uploaded_workspaces_bucket_name
  workspace_bucket_name                = module.spacelift.workspace_bucket_name

  # MQTT / IoT
  mqtt_broker_type = var.mqtt_broker_type

  # SQS
  create_sqs = var.create_sqs
  queue_arns = local.sqs_queue_arns_from_override != null ? local.sqs_queue_arns_from_override : module.spacelift.sqs_queue_arns

  # Service accounts & OIDC
  oidc_provider                    = module.eks.oidc_provider
  namespace                        = var.k8s_namespace
  server_service_account_name      = var.server_service_account_name
  drain_service_account_name       = var.drain_service_account_name
  scheduler_service_account_name   = var.scheduler_service_account_name
  vcs_gateway_service_account_name = var.vcs_gateway_service_account_name
}

module "kube_outputs" {
  source = "./modules/kube-outputs"

  aws_region    = var.aws_region
  k8s_namespace = var.k8s_namespace
  server_domain = var.server_domain
  license_token = var.license_token

  # Encryption
  encryption_type        = var.encryption_type
  kms_encryption_key_arn = coalesce(var.kms_encryption_key_arn, module.spacelift.kms_encryption_key_arn)
  kms_signing_key_arn    = coalesce(var.kms_signing_key_arn, module.spacelift.kms_signing_key_arn)

  # MQTT
  mqtt_broker_domain   = var.mqtt_broker_domain
  mqtt_broker_type     = var.mqtt_broker_type
  mqtt_broker_endpoint = local.mqtt_broker_endpoint

  # S3
  deliveries_bucket_name               = module.spacelift.deliveries_bucket_name
  large_queue_messages_bucket_name     = module.spacelift.large_queue_messages_bucket_name
  modules_bucket_name                  = module.spacelift.modules_bucket_name
  policy_inputs_bucket_name            = module.spacelift.policy_inputs_bucket_name
  run_logs_bucket_name                 = module.spacelift.run_logs_bucket_name
  states_bucket_name                   = module.spacelift.states_bucket_name
  user_uploaded_workspaces_bucket_name = module.spacelift.user_uploaded_workspaces_bucket_name
  workspace_bucket_name                = module.spacelift.workspace_bucket_name
  metadata_bucket_name                 = module.spacelift.metadata_bucket_name
  uploads_bucket_name                  = module.spacelift.uploads_bucket_name
  uploads_bucket_url                   = module.spacelift.uploads_bucket_url

  # SQS
  create_sqs               = var.create_sqs
  sqs_queue_names_override = var.sqs_queue_names_override
  sqs_queue_urls_generated = module.spacelift.sqs_queue_urls

  # Database
  database_url           = module.spacelift.database_url
  database_read_only_url = module.spacelift.database_read_only_url

  # ECR
  ecr_backend_repository_url  = module.spacelift.ecr_backend_repository_url
  ecr_launcher_repository_url = module.spacelift.ecr_launcher_repository_url

  # Spacelift
  spacelift_version    = var.spacelift_version
  spacelift_public_api = var.spacelift_public_api
  admin_username       = var.admin_username
  admin_password       = var.admin_password

  # Ingress
  public_subnet_ids = local.public_subnet_ids
  server_acm_arn    = var.server_acm_arn

  # Service accounts & IAM roles
  server_service_account_name      = var.server_service_account_name
  drain_service_account_name       = var.drain_service_account_name
  scheduler_service_account_name   = var.scheduler_service_account_name
  vcs_gateway_service_account_name = var.vcs_gateway_service_account_name
  server_role_arn                  = module.iam.server_role_arn
  drain_role_arn                   = module.iam.drain_role_arn
  scheduler_role_arn               = module.iam.scheduler_role_arn
  vcs_gateway_role_arn             = module.iam.vcs_gateway_role_arn

  # VCS Gateway
  vcs_gateway_domain  = var.vcs_gateway_domain
  vcs_gateway_acm_arn = var.vcs_gateway_acm_arn
}
