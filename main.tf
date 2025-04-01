data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "random_uuid" "suffix" {
}

locals {
  unique_suffix = lower(substr(random_uuid.suffix.id, 0, 5))
  cluster_name  = coalesce(var.eks_cluster_name, "spacelift-cluster-${module.spacelift.unique_suffix}")

  vpc_id                      = var.create_vpc ? module.spacelift.vpc_id : var.vpc_id
  private_subnet_ids          = var.create_vpc ? module.spacelift.private_subnet_ids : var.private_subnet_ids
  public_subnet_ids           = var.create_vpc ? module.spacelift.public_subnet_ids : var.public_subnet_ids
  server_security_group_id    = var.create_vpc ? module.spacelift.server_security_group_id : var.server_security_group_id
  drain_security_group_id     = var.create_vpc ? module.spacelift.drain_security_group_id : var.drain_security_group_id
  scheduler_security_group_id = var.create_vpc ? module.spacelift.scheduler_security_group_id : var.scheduler_security_group_id
}

module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-selfhosted"

  unique_suffix = local.unique_suffix
  region        = var.aws_region
  kms_arn       = var.kms_arn

  create_vpc           = var.create_vpc
  vpc_cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = true

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
  rds_delete_protection_enabled          = var.rds_delete_protection_enabled
  rds_engine_version                     = var.rds_engine_version
  rds_engine_mode                        = var.rds_engine_mode
  rds_username                           = var.rds_username
  rds_instance_configuration             = var.rds_instance_configuration
  rds_preferred_backup_window            = var.rds_preferred_backup_window
  rds_backup_retention_period            = var.rds_backup_retention_period

  website_endpoint = "https://${var.server_domain}"

  s3_retain_on_destroy       = var.s3_retain_on_destroy
  number_of_images_to_retain = var.number_of_images_to_retain
  ecr_force_delete           = var.ecr_force_delete
}

module "iam" {
  source = "./modules/iam"

  unique_suffix                        = module.spacelift.unique_suffix
  aws_account_id                       = data.aws_caller_identity.current.account_id
  aws_partition                        = data.aws_partition.current.partition
  aws_dns_suffix                       = data.aws_partition.current.dns_suffix
  kms_key_arn                          = module.spacelift.kms_key_arn
  kms_encryption_key_arn               = module.spacelift.kms_encryption_key_arn
  kms_signing_key_arn                  = module.spacelift.kms_signing_key_arn
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
  oidc_provider                        = module.eks.oidc_provider
  namespace                            = var.k8s_namespace
  server_service_account_name          = var.server_service_account_name
  drain_service_account_name           = var.drain_service_account_name
  scheduler_service_account_name       = var.scheduler_service_account_name
}

module "lb" {
  source = "./modules/lb"

  unique_suffix            = module.spacelift.unique_suffix
  vpc_id                   = local.vpc_id
  server_security_group_id = local.server_security_group_id
  server_port              = var.server_port
}
