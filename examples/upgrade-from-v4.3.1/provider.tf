provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      repo     = "github.com/spacelift-io/terraform-aws-eks-spacelift-selfhosted"
      testcase = "upgrade-from-v4.3.1"
    }
  }
}
