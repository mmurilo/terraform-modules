# AWS Terraform Bootstrap

This module creates an S3 bucket and a DynamoDB table to be used as a backend for Terraform state.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tf_state"></a> [tf\_state](#module\_tf\_state) | git@github.com:EverlongProject/aws-terraform-modules.git//terraform-aws-s3-bucket | aws-s3-v4.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.dynamodb-terraform-state-lock](https://registry.terraform.io/providers/HASHICORP/AWS/latest/docs/resources/dynamodb_table) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/HASHICORP/AWS/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.tfstate_bucket](https://registry.terraform.io/providers/HASHICORP/AWS/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | DynamoDB billing mode | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | S3 bucket name | `string` | `null` | no |
| <a name="input_creator"></a> [creator](#input\_creator) | n/a | `string` | `"terraform"` | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | n/a | `string` | `"tf-state-lock"` | no |
| <a name="input_enable_point_in_time_recovery"></a> [enable\_point\_in\_time\_recovery](#input\_enable\_point\_in\_time\_recovery) | Enable DynamoDB point-in-time recovery | `bool` | `true` | no |
| <a name="input_lifecycle_delete"></a> [lifecycle\_delete](#input\_lifecycle\_delete) | After how many days delete versioned objects | `number` | `90` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | DynamoDB read capacity units when using provisioned mode | `number` | `5` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to cretate resources | `string` | `null` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | DynamoDB write capacity units when using provisioned mode | `number` | `5` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tfstate_bucket_arn"></a> [tfstate\_bucket\_arn](#output\_tfstate\_bucket\_arn) | The TFState bucket ARN. |
| <a name="output_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#output\_tfstate\_bucket\_name) | The TFState bucket name. |
| <a name="output_tfstate_bucket_region"></a> [tfstate\_bucket\_region](#output\_tfstate\_bucket\_region) | The AWS region TFState bucket resides in. |
| <a name="output_tfstate_dynamodb_table"></a> [tfstate\_dynamodb\_table](#output\_tfstate\_dynamodb\_table) | The TFState Dynamodb table name. |
<!-- END_TF_DOCS -->