# ☁️ Terraform module for Spacelift on Elastic Kubernetes Service

This module creates the base infrastructure for a self-hosted Spacelift instance running on AWS EKS. The module is intended to be used alongside the EKS getting started guide in our documentation.

If you only want to deploy the Spacelift-specific infrastructure, and have an existing EKS cluster that you want to deploy Spacelift to, you may want to take a look at our [terraform-aws-spacelift-selfhosted](https://github.com/spacelift-io/terraform-aws-spacelift-selfhosted) and [terraform-aws-iam-spacelift-selfhosted](https://github.com/spacelift-io/terraform-aws-iam-spacelift-selfhosted) modules.

**Please note:** this module is intended as an example of how to quickly deploy Spacelift to EKS, and should not be used as an example of best-practices for deploying EKS clusters.

## State storage

Check out the [Terraform](https://developer.hashicorp.com/terraform/language/backend) or the [OpenTofu](https://opentofu.org/docs/language/settings/backends/configuration/) backend documentation for more information on how to configure the state storage.

> ⚠️ Do **not** import the state into Spacelift after the installation: that would cause circular dependencies, and in case you accidentally break the Spacelift installation, you wouldn't be able to fix it.

## ✨ Usage

```hcl
module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v1.0.0"

  aws_region = var.aws_region

  # The domain you want to host Spacelift on, for example spacelift.example.com.
  server_domain = var.server_domain
}
```

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
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v1.0.0"

  aws_region    = var.aws_region
  server_domain = var.server_domain

  # The domain workers should use to connect to the Spacelift MQTT broker. For example mqtt.spacelift.example.com.
  mqtt_broker_domain = var.mqtt_broker_domain
}
```

### Deploy into an existing VPC

```hcl
locals {
  # The name of the EKS cluster that will be created. This needs to be defined up
  # front to allow the VPC subnets to be tagged correctly.
  cluster_name = "spacelift-cluster"
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

module "spacelift" {
  source = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted?ref=v1.0.0"

  aws_region         = var.aws_region
  server_domain      = var.server_domain

  create_vpc         = false
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  # When defining your own VPC, you need to provide the database, server, drain and scheduler
  # security groups. Take a look at https://github.com/spacelift-io/terraform-aws-spacelift-selfhosted/blob/main/modules/network/security_groups.tf
  # for an example of how these should be defined.
  rds_security_group_ids      = [aws_security_group.database_sg.id]
  server_security_group_id    = aws_security_group.server_sg.id
  drain_security_group_id     = aws_security_group.drain_sg.id
  scheduler_security_group_id = aws_security_group.scheduler_sg.id

  eks_cluster_name = local.cluster_name
}
```

## 🚀 Release

To release a new version of the module, just create a new release with an appropriate tag in GitHub releases.
