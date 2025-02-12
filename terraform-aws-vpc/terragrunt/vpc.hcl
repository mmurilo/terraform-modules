terraform {
  source = "${local.base_source_url}?ref=${local.base_git_tag}"
}

locals {
  base_git_repo       = "EverlongProject/aws-terraform-modules"
  base_module_folder  = "terraform-aws-vpc"
  base_git_tag        = "aws-vpc-v0.1.1"
  base_source_url     = "git::git@github.com:${local.base_git_repo}.git//${local.base_module_folder}"
  global_locals       = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  s3_bucket_name      = local.global_locals.locals.s3_buckets.vpc_flow_logs_bucket
  log_destination_arn = "arn:aws:s3:::${local.s3_bucket_name}"
}

inputs = {
  enable_flow_log     = true
  flow_log_bucket_arn = local.log_destination_arn
}
