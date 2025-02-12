# Override the terraform.source attribute
// terraform {
//     source = "git::git@github.com:EverlongProject/aws-terraform-modules.git//<some_module>s?ref=<some_tag>"
// }

include "root" {
  path   = "${find_in_parent_folders()}"
  expose = true
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/eks-addons.hcl"
}

locals {
  root_locals = include.root.locals
  // tags        = merge(local.root_locals.account_vars.locals.tags, local.root_locals.region_vars.locals.tags)
}

inputs = {
  // tags = local.tags
}
