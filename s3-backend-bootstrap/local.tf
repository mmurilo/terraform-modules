locals {
  region      = var.region
  bucket_name = coalesce(var.bucket_name, "tf-state-bucket-${local.account_id}")
  account_id  = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}
