locals {
  # Extend node-to-node security group rules
  node_security_group_additional_rules = merge(var.node_security_group_additional_rules,
    {
      node_to_node_all = {
        description = "Node to node all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        self        = true
      }
      control_plane_to_node_all_traffic = {
        description                   = "Cluster API to Nodegroup all traffic"
        protocol                      = "-1"
        from_port                     = 0
        to_port                       = 0
        type                          = "ingress"
        source_cluster_security_group = true
      }
      ingress_from_vpc = {
        description = "Ingress from Same VPC"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        cidr_blocks = [data.aws_vpc.this.cidr_block]
      }
  })

  cluster_security_group_additional_rules = merge(
    var.cluster_security_group_additional_rules,
    {
      api_from_vpc = {
        description = "API from Same VPC"
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        type        = "ingress"
        cidr_blocks = [data.aws_vpc.this.cidr_block]
      }
      API_from_network = {
        description = "API from peered Networks"
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        type        = "ingress"
        cidr_blocks = var.cluster_allowed_cidrs
      }
  })
  cluster_addons = merge(
    var.enable_coredns ? {
      coredns = {
        most_recent = true
        preserve    = false
        timeouts = {
          create = "25m"
          delete = "10m"
        }
      }
    } : {},
    var.enable_kube_proxy ? {
      kube-proxy = {
        most_recent = true
        preserve    = false
      }
    } : {},
    var.enable_vpc_cni ? {
      vpc-cni = {
        most_recent              = true
        preserve                 = false
        service_account_role_arn = try(module.vpc_cni_irsa_role[0].iam_role_arn, null)
        # configuration_values = jsonencode({
        #   env = {
        #     ENABLE_PREFIX_DELEGATION = "true"
        #     WARM_PREFIX_TARGET       = "1"
        #   }
        # })
      }
    } : {},
    var.enable_aws_ebs_csi_driver ? {
      aws-ebs-csi-driver = {
        most_recent              = true
        preserve                 = false
        service_account_role_arn = try(module.ebs_csi_irsa_role[0].iam_role_arn, null)
      }
    } : {},
    var.enable_aws_efs_csi_driver ? {
      aws-efs-csi-driver = {
        most_recent              = true
        preserve                 = false
        service_account_role_arn = try(module.efs_csi_irsa_role[0].iam_role_arn, null)
      }
    } : {},
    var.enable_amazon_cloudwatch_observability ? {
      amazon-cloudwatch-observability = {
        most_recent              = true
        preserve                 = false
        service_account_role_arn = try(module.cloudwatch_irsa_role[0].iam_role_arn, null)
      }
    } : {},
    var.enable_snapshot_controller ? {
      snapshot-controller = {
        most_recent = true
        preserve    = false
      }
    } : {},
    var.enable_eks_pod_identity_agent ? {
      eks-pod-identity-agent = {
        most_recent = true
        preserve    = false
      }
    } : {},
    var.enable_eks_node_monitoring_agent ? {
      eks-node-monitoring-agent = {
        most_recent = true
        preserve    = false
      }
    } : {},
    var.cluster_addons
  )
  admin_access_entries = var.attach_sso_admin_access_entries ? {
    sso-AdminUsers = {
      kubernetes_groups = []
      principal_arn     = tolist(data.aws_iam_roles.admin_sso_roles.arns)[0]

      policy_associations = {
        ClusterAdmin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  } : {}
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_iam_roles" "admin_sso_roles" {
  name_regex  = "AWSReservedSSO_AWSAdministratorAccess_*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

################################################################################
# Cluster
################################################################################
module "eks" {
  # source = "./modules/terraform-aws-eks"
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  vpc_id                                   = var.vpc_id
  subnet_ids                               = var.subnet_ids
  control_plane_subnet_ids                 = var.control_plane_subnet_ids
  cluster_endpoint_private_access          = var.cluster_endpoint_private_access
  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  cluster_security_group_additional_rules  = local.cluster_security_group_additional_rules
  cluster_encryption_config                = var.cluster_encryption_config
  node_security_group_additional_rules     = local.node_security_group_additional_rules
  eks_managed_node_group_defaults          = var.eks_managed_node_group_defaults
  eks_managed_node_groups                  = var.eks_managed_node_groups
  cluster_enabled_log_types                = var.cluster_enabled_log_types
  authentication_mode                      = var.authentication_mode
  access_entries                           = merge(local.admin_access_entries, var.access_entries)
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  cluster_addons                           = local.cluster_addons
  tags                                     = var.tags
  cluster_tags                             = var.cluster_tags
}

################################################################################
# IRSA
################################################################################
module "vpc_cni_irsa_role" {
  source = "./modules/iam-role-for-service-accounts-eks"
  count  = var.enable_vpc_cni ? 1 : 0

  role_name                      = "vpc-cni-ipv4"
  attach_vpc_cni_policy          = true
  vpc_cni_enable_ipv4            = true
  vpc_cni_enable_cloudwatch_logs = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

module "ebs_csi_irsa_role" {
  source = "./modules/iam-role-for-service-accounts-eks"
  count  = var.enable_aws_ebs_csi_driver ? 1 : 0

  role_name             = "ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

module "efs_csi_irsa_role" {
  source = "./modules/iam-role-for-service-accounts-eks"
  count  = var.enable_aws_efs_csi_driver ? 1 : 0

  role_name             = "efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

module "cloudwatch_irsa_role" {
  source = "./modules/iam-role-for-service-accounts-eks"
  count  = var.enable_amazon_cloudwatch_observability ? 1 : 0

  role_name                              = "cloudwatch-observability"
  attach_cloudwatch_observability_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:cloudwatch-agent"]
    }
  }

  tags = var.tags
}
