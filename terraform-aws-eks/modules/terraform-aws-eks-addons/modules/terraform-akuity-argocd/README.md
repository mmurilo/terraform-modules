# Terraform Akuity Module

This module creates an Akuity ArgoCD cluster installation in the EKS cluster.

## Usage

basic usage:

```hcl
module "akuity" {
  source = "./modules/terraform-akuity-argocd"

  create = true

  cluster_name        = var.name
  akuity_name         = "my_cluster_agent"
  akuity_instance_id  = "0123456789"
  akuity_namespace    = "akuity"
  akuity_agent_size   = "small"

  tags = vars.tags
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_akp"></a> [akp](#requirement\_akp) | >= 0.7.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_akp"></a> [akp](#provider\_akp) | >= 0.7.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.40 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether the Akuity addon is enabled | `bool` | false | no |
| <a name="input_akuity_name"></a> [akuity\_name](#input\_akuity\_name) | Name of the Akuity installation | `string` | n/a | yes |
| <a name="input_akuity_instance_id"></a> [akuity\_instance\_id](#input\_akuity\_instance\_id) | Akuity instance ID | `string` | n/a | yes |
| <a name="input_akuity_namespace"></a> [akuity\_namespace](#input\_akuity\_namespace) | Akuity addon installation namespace | `string` | n/a | yes |
| <a name="input_akuity_agent_size"></a> [akuity\_agent\_size](#input\_akuity_\_agent\_size) | Akuity agent installation size. Must equal `small`, `medium`, or `large`. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | The Akuity cluster name |
| <a name="output_version"></a> [version](#output\_version) | The Akuity ArgoCD version |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The Akuity installation namespace |
<!-- END_TF_DOCS -->