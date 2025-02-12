data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "auth_token" {
  name = var.cluster_name
}

resource "akp_cluster" "managed_cluster" {
  count = var.create ? 1 : 0

  instance_id = var.akuity_instance_id
  kube_config = {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    token                  = data.aws_eks_cluster_auth.auth_token.token
    cluster_ca_certificate = sensitive(base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data))
  }
  name      = var.akuity_name
  namespace = var.akuity_namespace
  spec = {
    data = {
      size              = var.akuity_agent_size
      eks_addon_enabled = true
    }
  }

  labels = var.tags
}