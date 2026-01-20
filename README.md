# ☁️ Terraform module for Spacelift on Elastic Kubernetes Service

> [!IMPORTANT]
> ## 🔄 Upgrading to v3.0.0 - Breaking changes
>
> Click below to see the full upgrade guide with breaking changes.

<details>
<summary><h3>📋 Full v3.0.0 Upgrade Guide</h3></summary>

### Breaking Changes

#### Mandatory Version Parameters

Two previously optional parameters are now **required** and have no default values:

- **`eks_cluster_version`** - The Kubernetes version for your EKS cluster (previously defaulted to `"1.32"`)
- **`rds_engine_version`** - The PostgreSQL engine version for RDS (previously defaulted to `"16.6"`)

**Why this change?** Hardcoded defaults prevent us from ever updating them without causing unexpected infrastructure changes for existing users. Explicit version specification is simpler and gives you full control.

**Action Required:** You must explicitly set these values in your module configuration:

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v3.x.x"

  # New required parameters
  eks_cluster_version = "1.32"  # or your preferred Kubernetes version
  rds_engine_version  = "16.6"  # or your preferred PostgreSQL version

  # ... other variables
}
```

### Example Migration

**Before (v2.x.x):**
```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v2.0.0"

  aws_region    = var.aws_region
  server_domain = var.server_domain
}
```

**After (v3.0.0):**
```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v3.0.0"

  aws_region    = var.aws_region
  server_domain = var.server_domain

  eks_cluster_version = "1.32"  # Now required
  rds_engine_version  = "16.6"  # Now required
}
```

</details>

---

This module creates the base infrastructure for a self-hosted Spacelift instance running on AWS EKS. The module is intended to be used alongside the EKS getting started guide in our documentation.

**Please note:** this module is intended as an example of how to quickly deploy Spacelift to EKS, and should not be used as an example of best-practices for deploying EKS clusters.

## State storage

Check out the [Terraform](https://developer.hashicorp.com/terraform/language/backend) or the [OpenTofu](https://opentofu.org/docs/language/settings/backends/configuration/) backend documentation for more information on how to configure the state storage.

> ⚠️ Do **not** import the state into Spacelift after the installation: that would cause circular dependencies, and in case you accidentally break the Spacelift installation, you wouldn't be able to fix it.

## 🔐 IAM Permissions

To deploy this module, you'll need AWS credentials with the appropriate IAM permissions. A comprehensive IAM policy document with all required permissions is provided in [terraform-deployment-iam-policy.json](terraform-deployment-iam-policy.json). This policy includes permissions for:

- EKS cluster and node group management
- VPC and networking resources (subnets, route tables, security groups, NAT gateways, etc.)
- RDS Aurora database management
- S3 bucket management for storing Spacelift data
- ECR repository management for container images
- KMS key management for encryption
- IAM role and policy management
- CloudWatch logs management
- Load balancer management
- Auto Scaling groups for EKS node groups

You can attach this policy to the IAM user or role that will be used to deploy the infrastructure.

## ✨ Usage

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      "app"         = "spacelift-selfhosted"
      "environment" = "production"
    }
  }
}

module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v3.1.0"

  aws_region = var.aws_region

  eks_cluster_version = "1.34" # Optional: Kubernetes version. Omit to use latest available version.
  rds_engine_version  = "17.7" # Postgres version

  # Optional: Set upgrade policy to STANDARD for more frequent upgrades and lower cost
  eks_upgrade_policy = {
    support_type = "STANDARD"
  }

  # The domain you want to host Spacelift on, for example spacelift.example.com.
  server_domain = var.server_domain
}
```

> [!NOTE]
> Clusters running on a Kubernetes version that has completed its lifecycle will be auto-upgraded to the next version. With extended support (26 months total), upgrades happen less frequently but incur additional costs. With standard support (14 months), upgrades happen more frequently, helping ensure you receive the latest bugfixes. This is why we recommend explicitly setting `eks_upgrade_policy` to `STANDARD` and omitting the `eks_cluster_version` variable to use the latest stable version available from AWS EKS. For more information, see the [EKS cluster upgrades best practices](https://docs.aws.amazon.com/eks/latest/best-practices/cluster-upgrades.html).

The module creates:

- IAM resources
  - An IAM role for each Spacelift service that can be mapped to a Kubernetes service account.
- Network resources
  - A VPC containing public and private subnets.
  - NAT and Internet Gateways, and appropriate routes.
  - Security group rules to allow communication between the Spacelift components.
- Container registries
  - A private ECR for storing the Spacelift backend image.
  - A private ECR for storing the Spacelift launcher image.
- Database resources
  - An RDS Postgres cluster. An Aurora Serverless v2 instance is created by default, but you can modify this.
- Storage resources
  - Various S3 buckets for storing run metadata, run logs, workspaces, stack states etc.
- EKS cluster
  - A Kubernetes cluster to install Spacelift on.

## Module registries

The module is also available [on the OpenTofu registry](https://search.opentofu.org/module/spacelift-io/eks-spacelift-selfhosted/aws/latest) where you can browse the input and output variables.

## Examples

### External workers

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted"

  # other variables...

  # The domain workers should use to connect to the Spacelift MQTT broker. For example `mqtt.spacelift.example.com`.
  mqtt_broker_domain = var.mqtt_broker_domain
}
```

> [!NOTE]
> If `mqtt_broker_domain` is not specified, it defaults to the internal Kubernetes service DNS (`spacelift-mqtt.{namespace}.svc.cluster.local`), which is only reachable from within the cluster. External workers require a publicly accessible domain.

### Enable VCS Gateway

To enable the [VCS Gateway](https://docs.spacelift.io/concepts/vcs-agent-pools.html) for connecting remote VCS agents, provide the `vcs_gateway_domain` and `vcs_gateway_acm_arn` variables.

> [!IMPORTANT]
> The VCS Gateway requires its own ACM certificate, separate from the server certificate. This certificate must be valid for the VCS Gateway domain (e.g., `vcs-gateway.mycorp.io`), which is different from your main Spacelift server domain.

See a full example in the [examples/with-vcs-gateway](examples/with-vcs-gateway) directory.

### Use an existing EKS cluster

If you only want to deploy the Spacelift-specific infrastructure, and have an existing EKS cluster that you want to deploy Spacelift to, you may want to take a look at our [terraform-aws-spacelift-selfhosted](https://github.com/spacelift-io/terraform-aws-spacelift-selfhosted) and [terraform-aws-iam-spacelift-selfhosted](https://github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted) modules.

See below for an example.

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-spacelift-selfhosted"
  # ...
}

module "iam" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted//modules/iam"
  # ...
}

module "kube_outputs" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted//modules/kube-outputs"
  # ...
}
```

See a full example in the [examples/byo-eks-cluster](examples/byo-eks-cluster) directory.

```hcl
# Allow the cluster nodes to access the database.
resource "aws_vpc_security_group_ingress_rule" "cluster_database_ingress_rule" {
  # If you deploy into an existing VPC, don't use the module output here and provide the VPC ID yourself instead.
  security_group_id            = module.spacelift.database_security_group_id
  description                  = "Only accept TCP connections on appropriate port from EKS cluster nodes"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  // ID of the primary security group of the existing EKS cluster
  referenced_security_group_id = "sg-01234567890abcdef"
}
```

### Deploy into an existing VPC

```hcl
locals {
  # The name of the EKS cluster that will be created. This needs to be defined up
  # front to allow the VPC subnets to be tagged correctly.
  cluster_name = "spacelift-cluster"
  cluster_version = "1.34"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "spacelift-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  # DNS hostnames and DNS support are required for EKS.
  enable_dns_hostnames = true
  enable_dns_support   = true

  # We tag the subnets to let EKS know which subnets to use for running workloads and load balancing.
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
}

module "spacelift_eks" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted"

  # other variables...

  create_vpc         = false
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  # When defining your own VPC, you need to provide the database, server, drain and scheduler
  # security groups. Take a look at https://github.com/spacelift-io/terraform-aws-spacelift-selfhosted/blob/main/modules/network/security_groups.tf
  # for an example of how these should be defined.
  rds_security_group_ids      = [aws_security_group.database_sg.id]

  eks_cluster_name    = local.cluster_name
  eks_cluster_version = local.cluster_version
  rds_engine_version  = "17.7"
}
```

## Account-Level EBS Encryption

If your AWS account enforces EBS encryption by default, set `ebs_encryption.enabled = true`. This creates a dedicated KMS key for EBS volumes with the proper permissions for EKS Auto Mode.
To use an existing KMS key, set `ebs_encryption.kms_key_arn`, if unset the module will create a new key.

```hcl
module "spacelift_eks" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted"

  # other variables...

  ebs_encryption = {
    enabled = true
    kms_key_arn = "arn:aws:kms:us-west-1:123456789012:key/12345678-1234-1234-1234-123456789012" # dont set this to allow the module to create a new key
  }
}
```

After applying, patch your NodeClass to use the KMS key:

```bash
$(tofu output -raw ebs_encrypted_volumes_patch)
```

This addresses [terraform-aws-eks#3037](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3037). See [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/auto-kms.html) for details.

## 🚀 Release

To release a new version of the module, just create a new release with an appropriate tag in GitHub releases.
