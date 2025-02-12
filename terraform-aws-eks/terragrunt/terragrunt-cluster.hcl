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
  path = "${dirname(find_in_parent_folders())}/_envcommon/eks.hcl"
}

locals {
  root_locals = include.root.locals
  tags        = local.root_locals.aws_default_tags
}

inputs = {
  cluster_name = "name-${local.root_locals.aws_region}"
  eks_managed_node_groups = {
    general = {
      instance_types = ["m7i-flex.xlarge"]
    }
  }
  access_entries = {
    sso-AdminUsers = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${local.root_locals.aws_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_ef89c6a17f3d54fe"

      policy_associations = {
        ClusterAdmin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
            namespaces = []
          }
        }
      }
    }
  }

  tags = local.tags
}
