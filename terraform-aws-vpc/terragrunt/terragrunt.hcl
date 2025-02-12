# Override the terraform.source attribute
# terraform {
#   source = "git::git@github.com:EverlongProject/aws-terraform-modules.git//<some_module>s?ref=<some_tag>"
# }

include "root" {
  path   = "${find_in_parent_folders()}"
  expose = true
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/vpc.hcl"
}

locals {
  root_locals = include.root.locals
  # tags        = merge(local.root_locals.account_vars.locals.tags, local.root_locals.region_vars.locals.tags)
}

inputs = {
  vpc_name = "vpc-${lower(local.root_locals.aws_account_name)}-${local.root_locals.aws_region}"
  vpc_cidr = "10.4.0.0/20"
  for_eks  = true
  vpce_extra_interfaces = [
    "ecr.api",
    "ecr.dkr",
    "aps-workspaces",
    "aps",
  ]
  enable_vpn_gateway                 = true
  propagate_private_route_tables_vgw = true

  # tags = local.tags
}
