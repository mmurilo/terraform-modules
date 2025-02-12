terraform {
  source = "${local.base_source_url}?ref=${local.base_git_tag}"
}

#### Dependencies
dependencies { paths = [
  "${get_terragrunt_dir()}/../../vpc/",
] }

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../vpc/"
}

dependency "atlantis" {
  config_path = "${get_repo_root()}/infrastructure/shared-services/us-east-1/vpc"
}
####

locals {
  base_git_repo      = "EverlongProject/aws-terraform-modules"
  base_module_folder = "terraform-aws-eks"
  base_git_tag       = "aws-eks-v0.1.3"
  base_source_url    = "git::git@github.com:${local.base_git_repo}.git//${local.base_module_folder}"
  global_locals      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
}

inputs = {
  cluster_version                = "1.29"
  vpc_id                         = dependency.vpc.outputs.vpc_id
  subnet_ids                     = dependency.vpc.outputs.private_subnets # nodes
  control_plane_subnet_ids       = dependency.vpc.outputs.private_subnets
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = concat(
    [local.global_locals.locals.p81_vpn_cidr],
    formatlist("%s/32", dependency.atlantis.outputs.nat_public_ips)
  )
}

// prevent_destroy = true
