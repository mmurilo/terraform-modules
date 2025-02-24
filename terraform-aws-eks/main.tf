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
  cluster_security_group_additional_rules = merge(var.cluster_security_group_additional_rules,
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
  cluster_addons = merge(var.cluster_addons,
    {
      coredns = {
        most_recent = true
        preserve    = false
        timeouts = {
          create = "25m"
          delete = "10m"
        }
      }
      kube-proxy = {
        most_recent = true
        preserve    = false
      }
      vpc-cni = {
        most_recent              = true
        preserve                 = false
        service_account_role_arn = try(module.vpc_cni_irsa_role.iam_role_arn, null)
        # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
        # configuration_values = jsonencode({
        #   env = {
        #     ENABLE_PREFIX_DELEGATION = "true"
        #     WARM_PREFIX_TARGET       = "1"
        #   }
        # })
      }
      aws-ebs-csi-driver = {
        most_recent              = true
        preserve                 = false
        service_account_role_arn = try(module.ebs_csi_irsa_role.iam_role_arn, null)
      }
      # aws-efs-csi-driver = {
      #   most_recent              = true
      #   preserve                 = false
      #   service_account_role_arn = try(module.efs_csi_irsa_role.iam_role_arn, null)
      # }
      amazon-cloudwatch-observability = {
        most_recent              = true
        preserve                 = false
        service_account_role_arn = try(module.cloudwatch_irsa_role.iam_role_arn, null)
      }
      snapshot-controller = {
        most_recent = true
        preserve    = false
      }
      eks-pod-identity-agent = {
        most_recent = true
        preserve    = false
      }
  })
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source = "./modules/terraform-aws-eks"

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
  access_entries                           = var.access_entries
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  tags                                     = var.tags
  cluster_tags                             = var.cluster_tags
}

################################################################################
# IRSA
################################################################################

module "vpc_cni_irsa_role" {
  source = "./modules/iam-role-for-service-accounts-eks"

  role_name = "eks-addon-vpc-cni"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

module "ebs_csi_irsa_role" {
  source = "./modules/iam-role-for-service-accounts-eks"

  role_name = "eks-addon-ebs-csi"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# module "efs_csi_irsa_role" {
#   source = "./modules/iam-role-for-service-accounts-eks"

#   role_name = "eks-addon-efs-csi"

#   attach_efs_csi_policy = true

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
#     }
#   }
# }

module "cloudwatch_irsa_role" {
  source = "./modules/iam-role-for-service-accounts-eks"

  role_name = "eks-addon-cloudwatch-observability"

  attach_cloudwatch_observability_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:cloudwatch-agent"]
    }
  }
}

################################################################################
# Addons
################################################################################

module "eks_cluster_addons" {
  source = "./modules/terraform-aws-eks-addons"

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_version  = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
  eks_addons        = local.cluster_addons
  tags              = var.tags
}
