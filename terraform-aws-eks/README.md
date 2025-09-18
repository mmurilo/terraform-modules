# Terraform AWS EKS Module

This module creates an EKS cluster with managed node groups and EKS addons.

## Usage

basic usage:

```hcl
module "eks" {
  source = "git::ssh://git@github.com:<org>/<repo>.git//tf-aws-eks?ref=tf-aws-eks-v0.1.0"

  cluster_name    = var.name
  cluster_version = "1.27"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnets
}
```

## Access Entries

You can authenticate to EKS Kubernetes API endpoint using An AWS Identity and Access Management (IAM) principal (role or user) – This type requires authentication to IAM. Users can sign in to AWS as an IAM user or with a federated identity by using credentials provided through an identity source. Users can only sign in with a federated identity if your administrator previously set up identity federation using IAM roles. When users access AWS by using federation, they're indirectly assuming a role. When users use this type of identity, you:

- Can assign them Kubernetes permissions so that they can work with Kubernetes objects on your cluster. For more information about how to assign permissions to your IAM principals so that they're able to access Kubernetes objects on your cluster, see [Manage access entries](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html).

- Can assign them IAM permissions so that they can work with your Amazon EKS cluster and its resources using the Amazon EKS API, AWS CLI, AWS CloudFormation, AWS Management Console, or eksctl. For more information, see Actions defined by Amazon Elastic Kubernetes Service in the Service Authorization Reference.

### Access Policy

You can assign one or more access policies to access entries. Amazon EKS automatically grants the other types of access entries the permissions required to function properly in your cluster. Amazon EKS access policies include Kubernetes permissions, not IAM permissions. Before associating an access policy to an access entry, make sure that you're familiar with the Kubernetes permissions included in each access policy. For more information, see [Access policy permissions](https://docs.aws.amazon.com/eks/latest/userguide/access-policies.html#access-policy-permissions). If none of the access policies meet your requirements, then don't associate an access policy to an access entry. Instead, specify one or more group names for the access entry and create and manage Kubernetes role-based access control (RBAC) objects.

Available access policies:

- AmazonEKSAdminPolicy
- AmazonEKSClusterAdminPolicy
- AmazonEKSAdminViewPolicy
- AmazonEKSEditPolicy
- AmazonEKSViewPolicy

You can scope an access policy to all resources on a cluster or by specifying the name of one or more Kubernetes namespaces. You can use wildcard characters for a namespace name. For example, if you want to scope an access policy to all namespaces that start with `dev-`, you can specify `dev-*` as a namespace name. Make sure that the namespaces exist on your cluster and that your spelling matches the actual namespace name on the cluster. Amazon EKS doesn't confirm the spelling or existence of the namespaces on your cluster.

### Example

```hcl
  access_entries = {
    # One access entry with two policy associated
    ex-simple = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::123456789012:role/something"
      # Policy to edit on namespace default
      policy_associations = {
        edit = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
      # Policy to view on all cluster
      policy_associations = {
        view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }
  }
```

Example 2:

```hcl
  access_entries = {
    sso-PowerUsers = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::<account_id>:role/aws-reserved/sso.amazonaws.com/ca-central-1/AWSReservedSSO_PowerUserAccess_<hash>"

      policy_associations = {
        ClusterAdmin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    sso-View = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::<account_id>:role/AWSReservedSSO_PowerUserAccess_<hash>"

      policy_associations = {
        viewOnly = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default", "kube-system"]
            type       = "namespace"
          }
        }
      }
    }
  }
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_irsa_role"></a> [cloudwatch\_irsa\_role](#module\_cloudwatch\_irsa\_role) | ./modules/iam-role-for-service-accounts-eks | n/a |
| <a name="module_ebs_csi_irsa_role"></a> [ebs\_csi\_irsa\_role](#module\_ebs\_csi\_irsa\_role) | ./modules/iam-role-for-service-accounts-eks | n/a |
| <a name="module_efs_csi_irsa_role"></a> [efs\_csi\_irsa\_role](#module\_efs\_csi\_irsa\_role) | ./modules/iam-role-for-service-accounts-eks | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 21.3.1 |
| <a name="module_vpc_cni_irsa_role"></a> [vpc\_cni\_irsa\_role](#module\_vpc\_cni\_irsa\_role) | ./modules/iam-role-for-service-accounts-eks | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_roles.admin_sso_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of access entries to add to the cluster | `any` | `{}` | no |
| <a name="input_attach_sso_admin_access_entries"></a> [attach\_sso\_admin\_access\_entries](#input\_attach\_sso\_admin\_access\_entries) | Indicates whether or not to attach the SSO Admin access entries to the cluster | `bool` | `true` | no |
| <a name="input_authentication_mode"></a> [authentication\_mode](#input\_authentication\_mode) | The authentication mode for the cluster. Valid values are `CONFIG_MAP`, `API` or `API_AND_CONFIG_MAP` | `string` | `"API_AND_CONFIG_MAP"` | no |
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Map of extra cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name` | `any` | `{}` | no |
| <a name="input_cluster_allowed_cidrs"></a> [cluster\_allowed\_cidrs](#input\_cluster\_allowed\_cidrs) | CIDR block to allow access to the EKS cluster API | `list(string)` | <pre>[<br/>  "10.0.0.0/8"<br/>]</pre> | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | <pre>[<br/>  "audit",<br/>  "api",<br/>  "authenticator"<br/>]</pre> | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Configuration block with encryption configuration for the cluster. To disable secret encryption, set this value to `{}` | `any` | <pre>{<br/>  "resources": [<br/>    "secrets"<br/>  ]<br/>}</pre> | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_security_group_additional_rules"></a> [cluster\_security\_group\_additional\_rules](#input\_cluster\_security\_group\_additional\_rules) | List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source | `any` | `{}` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of additional tags to add to the cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`) | `string` | `null` | no |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane | `list(string)` | `[]` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of EKS managed node group definitions to create | `any` | <pre>{<br/>  "general": {}<br/>}</pre> | no |
| <a name="input_enable_amazon_cloudwatch_observability"></a> [enable\_amazon\_cloudwatch\_observability](#input\_enable\_amazon\_cloudwatch\_observability) | Enable Amazon CloudWatch Observability addon | `bool` | `true` | no |
| <a name="input_enable_aws_ebs_csi_driver"></a> [enable\_aws\_ebs\_csi\_driver](#input\_enable\_aws\_ebs\_csi\_driver) | Enable AWS EBS CSI driver addon | `bool` | `true` | no |
| <a name="input_enable_aws_efs_csi_driver"></a> [enable\_aws\_efs\_csi\_driver](#input\_enable\_aws\_efs\_csi\_driver) | Enable AWS EFS CSI driver addon | `bool` | `false` | no |
| <a name="input_enable_cluster_creator_admin_permissions"></a> [enable\_cluster\_creator\_admin\_permissions](#input\_enable\_cluster\_creator\_admin\_permissions) | Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry | `bool` | `true` | no |
| <a name="input_enable_coredns"></a> [enable\_coredns](#input\_enable\_coredns) | Enable CoreDNS addon | `bool` | `true` | no |
| <a name="input_enable_eks_node_monitoring_agent"></a> [enable\_eks\_node\_monitoring\_agent](#input\_enable\_eks\_node\_monitoring\_agent) | Enable EKS Node Monitoring Agent addon | `bool` | `true` | no |
| <a name="input_enable_eks_pod_identity_agent"></a> [enable\_eks\_pod\_identity\_agent](#input\_enable\_eks\_pod\_identity\_agent) | Enable EKS Pod Identity Agent addon | `bool` | `true` | no |
| <a name="input_enable_kube_proxy"></a> [enable\_kube\_proxy](#input\_enable\_kube\_proxy) | Enable kube-proxy addon | `bool` | `true` | no |
| <a name="input_enable_snapshot_controller"></a> [enable\_snapshot\_controller](#input\_enable\_snapshot\_controller) | Enable Snapshot Controller addon | `bool` | `true` | no |
| <a name="input_enable_vpc_cni"></a> [enable\_vpc\_cni](#input\_enable\_vpc\_cni) | Enable VPC CNI addon | `bool` | `true` | no |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source | `any` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster security group will be provisioned | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_sso_role"></a> [admin\_sso\_role](#output\_admin\_sso\_role) | IAM roles matching the AdminAccess pattern from AWS SSO |
| <a name="output_cloudwatch_irsa_role"></a> [cloudwatch\_irsa\_role](#output\_cloudwatch\_irsa\_role) | outputs from cloudwatch\_irsa\_role module |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | The Kubernetes version for the EKS cluster |
| <a name="output_ebs_csi_irsa_role"></a> [ebs\_csi\_irsa\_role](#output\_ebs\_csi\_irsa\_role) | outputs from ebs\_csi\_irsa\_role module |
| <a name="output_efs_csi_irsa_role"></a> [efs\_csi\_irsa\_role](#output\_efs\_csi\_irsa\_role) | outputs from efs\_csi\_irsa\_role module |
| <a name="output_eks"></a> [eks](#output\_eks) | outputs from EKS module |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Node subnet ids |
| <a name="output_vpc_cni_irsa_role"></a> [vpc\_cni\_irsa\_role](#output\_vpc\_cni\_irsa\_role) | outputs from vpc\_cni\_irsa\_role module |
<!-- END_TF_DOCS -->