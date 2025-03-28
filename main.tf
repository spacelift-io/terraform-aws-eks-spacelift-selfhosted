data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "random_uuid" "suffix" {
}

locals {
  unique_suffix = lower(substr(random_uuid.suffix.id, 0, 5))
  cluster_name  = "spacelift-cluster-${module.spacelift.unique_suffix}"
}

module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-selfhosted?ref=adamc%2FCU-8698eh69x-adjustments-for-eks"

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
  rds_subnet_ids                         = var.rds_subnet_ids
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

# TODO(adamc): make the SGs per Pod configurable, and if disabled just allow any node in the cluster access to the DB?
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version

  bootstrap_self_managed_addons = false

  # TODO(adamc): document this
  cluster_endpoint_public_access = true

  # TODO(adamc): document this
  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.spacelift.vpc_id
  subnet_ids = concat(module.spacelift.public_subnet_ids, module.spacelift.private_subnet_ids) # TODO(adamc): make these configurable?

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    # TODO(adamc): make the networking configurable
    subnet_ids                            = module.spacelift.private_subnet_ids
    attach_cluster_primary_security_group = true
  }

  # TODO(adamc): make this configurable
  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7a.large"]
      min_size       = 0
      max_size       = 10
      desired_size   = 0
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Name = "Spacelift cluster ${module.spacelift.unique_suffix}"
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          # Enable pod network interfaces to add support for security groups per pod (https://docs.aws.amazon.com/eks/latest/best-practices/sgpp.html)
          ENABLE_POD_ENI                    = "true"
          AWS_VPC_K8S_CNI_EXTERNALSNAT      = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
      })
    }
    kube-proxy = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller = true
  observability_tag                   = null
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
  vpc_id                   = module.spacelift.vpc_id
  server_security_group_id = module.spacelift.server_security_group_id
  server_port              = var.server_port
  mqtt_port                = var.mqtt_port
}
