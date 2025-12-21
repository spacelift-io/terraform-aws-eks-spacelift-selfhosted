# Bring Your Own EKS Cluster Example

This example demonstrates how to deploy Spacelift to an existing EKS cluster using the `terraform-aws-eks-spacelift-selfhosted` module.

## Overview

This configuration shows how to use the Spacelift modules when you already have an EKS cluster and want to deploy only the necessary AWS resources and Kubernetes configurations for Spacelift.

## What This Example Creates

- **Spacelift Infrastructure**: Core AWS resources (S3 buckets, RDS, ECR repositories, etc.) via the main spacelift module
- **IAM Roles**: Service account roles for Spacelift components via the `iam` module
- **Kubernetes Outputs**: Helm values and Kubernetes manifests via the `kube-outputs` module

## Prerequisites

- An existing EKS cluster
- kubectl configured to access your cluster
- Terraform or OpenTofu installed
- AWS CLI configured with appropriate permissions

## Usage

1. **Configure the variables**: Update the `locals` block in `main.tf` with your specific values:

```hcl
locals {
  aws_region       = "us-west-2"                    # Your AWS region
  aws_account_id   = "123456789012"                 # Your AWS account ID
  aws_dns_suffix   = "amazonaws.com"                # Your AWS DNS suffix
  aws_partition    = "aws"                          # Your AWS partition
  oidc_provider    = "https://oidc.eks.us-west-2.amazonaws.com/id/ABCD1234"  # Your EKS OIDC provider URL
  website_endpoint = "spacelift.example.com"        # Your Spacelift domain
}
```

2. **Deploy the infrastructure**:
```bash
terraform init
terraform plan
terraform apply
```

3. **Deploy to Kubernetes**: After the Terraform apply completes, use the outputs from the `kube-outputs` module to deploy Spacelift to your EKS cluster.

## Required Information

To use this example, you'll need the following information from your existing EKS cluster:

- **OIDC Provider URL**: The OpenID Connect provider URL for your EKS cluster
- **AWS Account ID**: The AWS account where your EKS cluster is deployed
- **AWS Region**: The region where your EKS cluster is deployed
- **Domain**: The domain where you want to access Spacelift

## Modules Used

- **spacelift**: Creates core AWS infrastructure (S3, RDS, ECR, etc.)
- **iam**: Creates IAM roles for Kubernetes service accounts
- **kube-outputs**: Generates Kubernetes manifests and Helm values

## Next Steps

After applying this configuration, you'll need to:

1. Apply the generated Kubernetes manifests to your cluster
2. Configure your DNS to point to the Spacelift ingress
3. Complete the Spacelift setup according to the documentation