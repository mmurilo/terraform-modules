<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_access_analyzer"></a> [iam\_access\_analyzer](#module\_iam\_access\_analyzer) | ./modules/iam-access-analyzer | n/a |
| <a name="module_iam_password_policy"></a> [iam\_password\_policy](#module\_iam\_password\_policy) | ./modules/iam-password-policy | n/a |
| <a name="module_security_controls"></a> [security\_controls](#module\_security\_controls) | ./modules/security-controls | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_iam_access_analyzer"></a> [create\_iam\_access\_analyzer](#input\_create\_iam\_access\_analyzer) | Whether to create IAM Access Analyzer resources | `bool` | `true` | no |
| <a name="input_create_iam_password_policy"></a> [create\_iam\_password\_policy](#input\_create\_iam\_password\_policy) | Whether to create IAM Password Policy resources | `bool` | `true` | no |
| <a name="input_create_security_controls"></a> [create\_security\_controls](#input\_create\_security\_controls) | Whether to create Security Controls resources | `bool` | `true` | no |
| <a name="input_iam_access_analyzer_archive_rules"></a> [iam\_access\_analyzer\_archive\_rules](#input\_iam\_access\_analyzer\_archive\_rules) | Map of archive rules to create for the analyzer | <pre>map(object({<br/>    filters = list(object({<br/>      criteria = string<br/>      contains = optional(list(string))<br/>      eq       = optional(list(string))<br/>      exists   = optional(string)<br/>      neq      = optional(list(string))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_access_analyzer_name"></a> [iam\_access\_analyzer\_name](#input\_iam\_access\_analyzer\_name) | Name of the analyzer. If not provided, a default name will be used based on analyzer type | `string` | `null` | no |
| <a name="input_iam_access_analyzer_type"></a> [iam\_access\_analyzer\_type](#input\_iam\_access\_analyzer\_type) | Type of analyzer. Valid values are ACCOUNT, ORGANIZATION, ORGANIZATION\_UNUSED\_ACCESS | `string` | `"ACCOUNT"` | no |
| <a name="input_iam_access_analyzer_unused_access_configuration"></a> [iam\_access\_analyzer\_unused\_access\_configuration](#input\_iam\_access\_analyzer\_unused\_access\_configuration) | Configuration for unused access analyzer. Only applicable when type is ORGANIZATION\_UNUSED\_ACCESS | <pre>object({<br/>    unused_access_age = number<br/>  })</pre> | `null` | no |
| <a name="input_iam_password_policy_allow_users_to_change_password"></a> [iam\_password\_policy\_allow\_users\_to\_change\_password](#input\_iam\_password\_policy\_allow\_users\_to\_change\_password) | Whether to allow users to change their own password | `bool` | `true` | no |
| <a name="input_iam_password_policy_aws_support_role_max_session_duration"></a> [iam\_password\_policy\_aws\_support\_role\_max\_session\_duration](#input\_iam\_password\_policy\_aws\_support\_role\_max\_session\_duration) | Maximum session duration (in seconds) for the AWS Support role | `number` | `3600` | no |
| <a name="input_iam_password_policy_aws_support_role_name"></a> [iam\_password\_policy\_aws\_support\_role\_name](#input\_iam\_password\_policy\_aws\_support\_role\_name) | The name of the AWS Support role | `string` | `"AWSSupport-IncidentManagement"` | no |
| <a name="input_iam_password_policy_aws_support_role_path"></a> [iam\_password\_policy\_aws\_support\_role\_path](#input\_iam\_password\_policy\_aws\_support\_role\_path) | The path for the AWS Support role | `string` | `"/"` | no |
| <a name="input_iam_password_policy_aws_support_role_require_mfa"></a> [iam\_password\_policy\_aws\_support\_role\_require\_mfa](#input\_iam\_password\_policy\_aws\_support\_role\_require\_mfa) | Whether to require MFA for assuming the AWS Support role | `bool` | `true` | no |
| <a name="input_iam_password_policy_aws_support_role_tags"></a> [iam\_password\_policy\_aws\_support\_role\_tags](#input\_iam\_password\_policy\_aws\_support\_role\_tags) | A map of tags to apply to the AWS Support role (in addition to common tags) | `map(string)` | `{}` | no |
| <a name="input_iam_password_policy_aws_support_role_trusted_entities"></a> [iam\_password\_policy\_aws\_support\_role\_trusted\_entities](#input\_iam\_password\_policy\_aws\_support\_role\_trusted\_entities) | List of AWS account ARNs or IAM user/role ARNs that can assume the AWS Support role | `list(string)` | `[]` | no |
| <a name="input_iam_password_policy_create"></a> [iam\_password\_policy\_create](#input\_iam\_password\_policy\_create) | Whether to create the IAM password policy | `bool` | `true` | no |
| <a name="input_iam_password_policy_create_aws_support_role"></a> [iam\_password\_policy\_create\_aws\_support\_role](#input\_iam\_password\_policy\_create\_aws\_support\_role) | Whether to create an AWS Support role for incident management (SecurityHub IAM.18) | `bool` | `true` | no |
| <a name="input_iam_password_policy_hard_expiry"></a> [iam\_password\_policy\_hard\_expiry](#input\_iam\_password\_policy\_hard\_expiry) | Whether users are prevented from setting a new password after their password has expired | `bool` | `false` | no |
| <a name="input_iam_password_policy_max_password_age"></a> [iam\_password\_policy\_max\_password\_age](#input\_iam\_password\_policy\_max\_password\_age) | The number of days that an IAM user password is valid | `number` | `90` | no |
| <a name="input_iam_password_policy_minimum_password_length"></a> [iam\_password\_policy\_minimum\_password\_length](#input\_iam\_password\_policy\_minimum\_password\_length) | Minimum length to require for IAM user passwords | `number` | `14` | no |
| <a name="input_iam_password_policy_password_reuse_prevention"></a> [iam\_password\_policy\_password\_reuse\_prevention](#input\_iam\_password\_policy\_password\_reuse\_prevention) | The number of previous passwords that users are prevented from reusing | `number` | `24` | no |
| <a name="input_iam_password_policy_require_lowercase_characters"></a> [iam\_password\_policy\_require\_lowercase\_characters](#input\_iam\_password\_policy\_require\_lowercase\_characters) | Whether to require lowercase characters for IAM user passwords | `bool` | `true` | no |
| <a name="input_iam_password_policy_require_numbers"></a> [iam\_password\_policy\_require\_numbers](#input\_iam\_password\_policy\_require\_numbers) | Whether to require numbers for IAM user passwords | `bool` | `true` | no |
| <a name="input_iam_password_policy_require_symbols"></a> [iam\_password\_policy\_require\_symbols](#input\_iam\_password\_policy\_require\_symbols) | Whether to require symbols for IAM user passwords | `bool` | `true` | no |
| <a name="input_iam_password_policy_require_uppercase_characters"></a> [iam\_password\_policy\_require\_uppercase\_characters](#input\_iam\_password\_policy\_require\_uppercase\_characters) | Whether to require uppercase characters for IAM user passwords | `bool` | `true` | no |
| <a name="input_security_controls_create_ebs_kms_key"></a> [security\_controls\_create\_ebs\_kms\_key](#input\_security\_controls\_create\_ebs\_kms\_key) | Whether to create a dedicated KMS key for EBS encryption | `bool` | `false` | no |
| <a name="input_security_controls_ebs_encryption_enabled"></a> [security\_controls\_ebs\_encryption\_enabled](#input\_security\_controls\_ebs\_encryption\_enabled) | Whether or not default EBS encryption is enabled | `bool` | `true` | no |
| <a name="input_security_controls_ebs_kms_key_alias"></a> [security\_controls\_ebs\_kms\_key\_alias](#input\_security\_controls\_ebs\_kms\_key\_alias) | The alias name for the EBS KMS key (must start with 'alias/') | `string` | `"alias/cis-hardening-ebs-encryption"` | no |
| <a name="input_security_controls_ebs_kms_key_arn"></a> [security\_controls\_ebs\_kms\_key\_arn](#input\_security\_controls\_ebs\_kms\_key\_arn) | The ARN of the AWS KMS key to use for EBS encryption | `string` | `null` | no |
| <a name="input_security_controls_ebs_kms_key_deletion_window"></a> [security\_controls\_ebs\_kms\_key\_deletion\_window](#input\_security\_controls\_ebs\_kms\_key\_deletion\_window) | Duration in days after which the key is deleted after destruction of the resource | `number` | `7` | no |
| <a name="input_security_controls_ebs_kms_key_rotation"></a> [security\_controls\_ebs\_kms\_key\_rotation](#input\_security\_controls\_ebs\_kms\_key\_rotation) | Whether to enable automatic rotation of the KMS key | `bool` | `true` | no |
| <a name="input_security_controls_enable_ebs_encryption_by_default"></a> [security\_controls\_enable\_ebs\_encryption\_by\_default](#input\_security\_controls\_enable\_ebs\_encryption\_by\_default) | Whether to enable EBS encryption by default | `bool` | `true` | no |
| <a name="input_security_controls_enable_s3_account_public_access_block"></a> [security\_controls\_enable\_s3\_account\_public\_access\_block](#input\_security\_controls\_enable\_s3\_account\_public\_access\_block) | Whether to enable S3 account public access block configuration | `bool` | `true` | no |
| <a name="input_security_controls_s3_block_public_acls"></a> [security\_controls\_s3\_block\_public\_acls](#input\_security\_controls\_s3\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for buckets in this account | `bool` | `true` | no |
| <a name="input_security_controls_s3_block_public_policy"></a> [security\_controls\_s3\_block\_public\_policy](#input\_security\_controls\_s3\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for buckets in this account | `bool` | `true` | no |
| <a name="input_security_controls_s3_ignore_public_acls"></a> [security\_controls\_s3\_ignore\_public\_acls](#input\_security\_controls\_s3\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for buckets in this account | `bool` | `true` | no |
| <a name="input_security_controls_s3_restrict_public_buckets"></a> [security\_controls\_s3\_restrict\_public\_buckets](#input\_security\_controls\_s3\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for buckets in this account | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_information"></a> [account\_information](#output\_account\_information) | AWS account information and configuration |
| <a name="output_aws_support_role_arn"></a> [aws\_support\_role\_arn](#output\_aws\_support\_role\_arn) | ARN of the AWS Support role (if created) |
| <a name="output_aws_support_role_enabled"></a> [aws\_support\_role\_enabled](#output\_aws\_support\_role\_enabled) | Whether AWS Support role is enabled (if created) |
| <a name="output_aws_support_role_name"></a> [aws\_support\_role\_name](#output\_aws\_support\_role\_name) | Name of the AWS Support role (if created) |
| <a name="output_aws_support_role_trusted_entities"></a> [aws\_support\_role\_trusted\_entities](#output\_aws\_support\_role\_trusted\_entities) | List of trusted entities that can assume the AWS Support role (including defaults) |
| <a name="output_aws_support_role_uses_default_trusted_entities"></a> [aws\_support\_role\_uses\_default\_trusted\_entities](#output\_aws\_support\_role\_uses\_default\_trusted\_entities) | Whether the AWS Support role is using default trusted entities (current account root) |
| <a name="output_compliance_summary"></a> [compliance\_summary](#output\_compliance\_summary) | Summary of compliance status for all security controls |
| <a name="output_ebs_default_kms_key_arn"></a> [ebs\_default\_kms\_key\_arn](#output\_ebs\_default\_kms\_key\_arn) | ARN of the KMS key used for EBS default encryption (if created) |
| <a name="output_ebs_encryption_by_default_enabled"></a> [ebs\_encryption\_by\_default\_enabled](#output\_ebs\_encryption\_by\_default\_enabled) | Whether EBS encryption by default is enabled (if created) |
| <a name="output_iam_access_analyzer"></a> [iam\_access\_analyzer](#output\_iam\_access\_analyzer) | IAM Access Analyzer module outputs |
| <a name="output_iam_access_analyzer_arn"></a> [iam\_access\_analyzer\_arn](#output\_iam\_access\_analyzer\_arn) | ARN of the IAM Access Analyzer (if created) |
| <a name="output_iam_access_analyzer_name"></a> [iam\_access\_analyzer\_name](#output\_iam\_access\_analyzer\_name) | Name of the IAM Access Analyzer (if created) |
| <a name="output_iam_password_policy"></a> [iam\_password\_policy](#output\_iam\_password\_policy) | IAM Password Policy module outputs |
| <a name="output_modules_deployed"></a> [modules\_deployed](#output\_modules\_deployed) | Status of which modules were deployed |
| <a name="output_password_policy_arn"></a> [password\_policy\_arn](#output\_password\_policy\_arn) | ARN of the IAM password policy (if created) |
| <a name="output_quick_reference"></a> [quick\_reference](#output\_quick\_reference) | Quick reference for key resources created |
| <a name="output_s3_account_public_access_block_enabled"></a> [s3\_account\_public\_access\_block\_enabled](#output\_s3\_account\_public\_access\_block\_enabled) | Whether S3 account public access block is enabled (if created) |
| <a name="output_security_controls"></a> [security\_controls](#output\_security\_controls) | Security Controls module outputs |
<!-- END_TF_DOCS -->