# AWS Terraform Bootstrap

This module creates an S3 bucket to be used as a backend for Terraform state.

## Usage

```bash
terraform init
terraform apply
```

## Outputs

Outputs are used as inputs for the backend configuration in the root module.

## State

This is a bootstrap module and should be run only once. The state file is stored locally.

## Import

A import file is provided to import the resources into the state file if needed.

- Rename the file to `import.tf` and run `terraform apply` command.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tf_state"></a> [tf\_state](#module\_tf\_state) | terraform-aws-modules/s3-bucket/aws | = 5.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.tfstate_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | S3 bucket name | `string` | `null` | no |
| <a name="input_creator"></a> [creator](#input\_creator) | n/a | `string` | `"terraform"` | no |
| <a name="input_lifecycle_delete"></a> [lifecycle\_delete](#input\_lifecycle\_delete) | After how many days delete versioned objects | `number` | `90` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to create resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tfstate_bucket_arn"></a> [tfstate\_bucket\_arn](#output\_tfstate\_bucket\_arn) | The TFState bucket ARN. |
| <a name="output_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#output\_tfstate\_bucket\_name) | The TFState bucket name. |
| <a name="output_tfstate_bucket_region"></a> [tfstate\_bucket\_region](#output\_tfstate\_bucket\_region) | The AWS region TFState bucket resides in. |
<!-- END_TF_DOCS -->