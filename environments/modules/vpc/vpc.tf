resource "aws_vpc" "main" {
  #checkov:skip=CKV2_AWS_11: VPC flow logs are omitted to reduce cost for the short-lived demo
  #checkov:skip=CKV2_AWS_12: Default security group is unused; all resources use dedicated security groups
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc-main"
  })
}
