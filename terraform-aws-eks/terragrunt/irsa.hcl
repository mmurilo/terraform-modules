terraform {
  source = "${local.base_source_url}?ref=${local.base_git_tag}"
}

#### Dependencies
dependency "eks" {
  config_path = "${get_terragrunt_dir()}/../cluster/"
}

dependencies { paths = [
  "${get_terragrunt_dir()}/../cluster/",
] }
####

locals {
  base_git_repo      = "EverlongProject/aws-terraform-modules"
  base_module_folder = "terraform-aws-eks/modules/terraform-aws-eks-irsa"
  base_git_tag       = "aws-eks-v0.1.4"
  base_source_url    = "git::git@github.com:${local.base_git_repo}.git//${local.base_module_folder}"
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
}

// prevent_destroy = true

generate "kubernetes_provider" {
  path      = "helm_providers.tf"
  if_exists = "overwrite"
  contents  = <<-EOF

data "aws_eks_cluster_auth" "this" {
  name  = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
EOF
}