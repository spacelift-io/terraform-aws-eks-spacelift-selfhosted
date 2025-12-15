# KMS key for EBS volume encryption when account enforces encryption
# This is required to work around https://github.com/terraform-aws-modules/terraform-aws-eks/issues/3037
# When an AWS account enforces EBS encryption, EKS Auto Mode requires explicit KMS key permissions

locals {
  create_ebs_key  = var.ebs_encryption.enabled && var.ebs_encryption.kms_key_arn == null
  ebs_kms_key_arn = local.create_ebs_key ? aws_kms_key.ebs[0].arn : var.ebs_encryption.kms_key_arn
}

data "aws_iam_policy_document" "ebs_kms_key_policy" {
  count = local.create_ebs_key ? 1 : 0

  # Allow root account to manage the key
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }

  # Allow EKS ClusterServiceRole to use the key for EBS encryption operations
  statement {
    sid    = "Allow use of the key for EKS Auto Mode"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [module.eks.cluster_iam_role_arn]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }

  # Allow EKS ClusterServiceRole to create grants for EBS volumes
  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [module.eks.cluster_iam_role_arn]
    }

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_kms_key" "ebs" {
  count = local.create_ebs_key ? 1 : 0

  description             = "KMS key for EBS volume encryption in EKS cluster ${local.cluster_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.ebs_kms_key_policy[0].json

  tags = merge(
    {
      Name = "eks-ebs-encryption-${module.spacelift.unique_suffix}"
    },
    {
      "eks-cluster-name" = local.cluster_name
    }
  )
}

resource "aws_kms_alias" "ebs" {
  count = local.create_ebs_key ? 1 : 0

  name          = "alias/eks-ebs-${module.spacelift.unique_suffix}"
  target_key_id = aws_kms_key.ebs[0].key_id
}
