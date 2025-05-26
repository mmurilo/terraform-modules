variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
  default     = null
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = []
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster. To disable secret encryption, set this value to `{}`"
  type        = any
  default = {
    resources = ["secrets"]
  }
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}

################################################################################
# Cluster Security Group
################################################################################
variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
  default     = null
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

variable "cluster_allowed_cidrs" {
  description = "CIDR block to allow access to the EKS cluster API"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

################################################################################
# Node Security Group
################################################################################
variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

################################################################################
# EKS Addons
################################################################################
variable "cluster_addons" {
  description = "Map of extra cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}

variable "enable_coredns" {
  description = "Enable CoreDNS addon"
  type        = bool
  default     = true
}

variable "enable_kube_proxy" {
  description = "Enable kube-proxy addon"
  type        = bool
  default     = true
}

variable "enable_vpc_cni" {
  description = "Enable VPC CNI addon"
  type        = bool
  default     = true
}

variable "enable_aws_ebs_csi_driver" {
  description = "Enable AWS EBS CSI driver addon"
  type        = bool
  default     = true
}

variable "enable_aws_efs_csi_driver" {
  description = "Enable AWS EFS CSI driver addon"
  type        = bool
  default     = false
}

variable "enable_amazon_cloudwatch_observability" {
  description = "Enable Amazon CloudWatch Observability addon"
  type        = bool
  default     = true
}

variable "enable_snapshot_controller" {
  description = "Enable Snapshot Controller addon"
  type        = bool
  default     = true
}

variable "enable_eks_pod_identity_agent" {
  description = "Enable EKS Pod Identity Agent addon"
  type        = bool
  default     = true
}

variable "enable_eks_node_monitoring_agent" {
  description = "Enable EKS Node Monitoring Agent addon"
  type        = bool
  default     = true
}

################################################################################
# EKS Managed Node Group
################################################################################

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default = {
    general = {
      # instance_types = ["m6a.2xlarge", "m6i.2xlarge", "m7a.2xlarge", "m7i.2xlarge"]
      # labels = {
      #   role = "general"
      # }
    }
  }
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  type = object({
    instance_types       = list(string)
    capacity_type        = string
    ami_type             = string
    min_size             = number
    max_size             = number
    desired_size         = number
    labels               = map(string)
    taints               = any
    force_update_version = bool
    tags                 = map(string)
  })
  default = {
    capacity_type        = "ON_DEMAND"
    instance_types       = ["m7a.2xlarge", "m7i.2xlarge", "m7i-flex.2xlarge"]
    ami_type             = null #"AL2_ARM_64"
    min_size             = 1
    max_size             = 3
    desired_size         = 1
    labels               = {}
    taints               = {}
    force_update_version = true
    tags                 = {}
  }
}

################################################################################
# Access Entry
################################################################################

variable "authentication_mode" {
  description = "The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP`"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = true
}

variable "attach_sso_admin_access_entries" {
  description = "Indicates whether or not to attach the SSO Admin access entries to the cluster"
  type        = bool
  default     = true
}
