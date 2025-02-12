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
  base_module_folder = "terraform-aws-eks/modules/terraform-aws-eks-addons"
  base_git_tag       = "aws-eks-v0.3.1"
  base_source_url    = "git::git@github.com:${local.base_git_repo}.git//${local.base_module_folder}"
}


inputs = {
  cluster_name      = dependency.eks.outputs.cluster_name
  cluster_version   = dependency.eks.outputs.cluster_version
  cluster_endpoint  = dependency.eks.outputs.eks.cluster_endpoint
  oidc_provider_arn = dependency.eks.outputs.eks.oidc_provider_arn

  enable_akuity                                = false #! removed because of issue `feature application_set_controller is not available`
  enable_aws_load_balancer_controller          = true
  enable_cluster_autoscaler                    = true
  enable_metrics_server                        = true
  enable_secrets_store_csi_driver              = true
  enable_secrets_store_csi_driver_provider_aws = true
  enable_gar_registry_secret                   = true

  akuity = {
    instance_id = "gcvh1dy1t7yb0t5a" #TODO: Change to prod instance
    name        = dependency.eks.outputs.cluster_name
    # akuity_argocd_version = "v2.12.3-ak.39"
  }

  # gar_registry = {
  #   email = 
  # }

  aws_load_balancer_controller = {
    chart_version = "1.7.1"
  }
  cluster_autoscaler = {
    chart_version = "9.37.0"
  }
  metrics_server = {
    chart_version = "3.12.1"
  }
  secrets_store_csi_driver = {
    chart_version = "1.4.6"
    set = [
      {
        name  = "syncSecret.enabled"
        value = true
      }
    ]
  }
  secrets_store_csi_driver_provider_aws = {
    chart_version = "0.3.10"
  }
}



generate "helm_provider" {
  path      = "helm_providers.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
data "aws_eks_cluster" "this" {
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name  = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "main"
}

data "aws_ssm_parameter" "akp_key_id" {
  provider = aws.main
  name     = "/eks/AKUITY_API_KEY_ID"
}

data "aws_ssm_parameter" "akp_key_secret" {
  provider = aws.main
  name     = "/eks/AKUITY_API_KEY_SECRET"
}

provider "akp" {
  org_name       = "${local.akuity_org}"
  api_key_id     = data.aws_ssm_parameter.akp_key_id.value
  api_key_secret = data.aws_ssm_parameter.akp_key_secret.value
}

EOF
}
