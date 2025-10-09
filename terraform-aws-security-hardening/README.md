## AWS Security Hardening (New) – Org/Global + StackSets

This module delivers a dynamic, organization-wide security baseline using two submodules:

- **cfn-stacksets**: CloudFormation StackSets (service-managed) to auto-apply per-account baselines to existing and future accounts in targeted OUs (S3 Account Public Access Block, EBS encryption by default, IAM Account Password Policy, AWS Support Role)
- **cloudtrail-s3-logging**: CloudTrail S3 data events logging for SecurityHub S3.22, S3.23, CloudTrail.7, and S3.5 compliance

The module also directly deploys IAM Access Analyzer at the organization level for external access detection and unused access analysis.

### Quick Start

```hcl
module "security_hardening" {
  source = "../terraform-aws-security-hardening-new"

  # Root controls
  enable_stacksets = true

  # IAM Access Analyzer (organization level)
  create_access_analyzer              = true
  access_analyzer_type                = "ORGANIZATION"
  access_analyzer_name                = "org-external-access"
  
  # Centralized Root Access Management (organization level - IAM.6 compliance)
  enable_centralized_root_access      = true
  centralized_root_access_features    = ["RootCredentialsManagement", "RootSessions"]
  
  # Optional: Unused access analyzer configuration
  # access_analyzer_type = "ORGANIZATION_UNUSED_ACCESS"
  # access_analyzer_unused_access_configuration = {
  #   unused_access_age = 90
  # }
  
  # Optional: Archive rules to suppress findings
  # access_analyzer_archive_rules = {
  #   "SuppressLambdaFunction" = {
  #     filters = [{
  #       criteria = "resourceType"
  #       eq       = ["AWS::Lambda::Function"]
  #     }]
  #   }
  # }

  # StackSets (per-account baseline via OUs)
  stacksets_organizational_unit_ids = [var.workloads_ou_id]
  stacksets_regions                 = ["us-east-1"]
  stackset_name                     = "org-baseline-security"

  # Per-account controls
  s3_pab_block_public_acls        = true
  s3_pab_block_public_policy      = true
  s3_pab_ignore_public_acls       = true
  s3_pab_restrict_public_buckets  = true
  
  # EBS Encryption Configuration (Enhanced with KMS key creation)
  ebs_encryption_by_default       = true
  
  # NEW: Create dedicated KMS key for EBS encryption (recommended)
  create_ebs_kms_key              = true
  ebs_kms_key_alias               = "alias/org-baseline-ebs-encryption"
  ebs_kms_key_rotation            = true
  ebs_kms_key_deletion_window     = 30
  
  # Alternative: Use existing KMS key (if create_ebs_kms_key = false)
  # ebs_default_kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Password policy is applied only in us-east-1 by template guard
  create_password_policy                  = true
  password_min_length                     = 14
  password_require_symbols                = true
  password_require_numbers                = true
  password_require_uppercase              = true
  password_require_lowercase              = true
  password_allow_users_to_change          = true
  password_max_age                        = 90
  password_reuse_prevention               = 24
  password_hard_expiry                    = false

  # AWS Support Role (per-account via StackSets)
  create_aws_support_role                 = true
  aws_support_role_name                   = "AWSSupport-IncidentManagement"
  aws_support_role_require_mfa            = true

  # CloudTrail S3 Logging (Management Account)
  enable_cloudtrail                       = true
  cloudtrail_name                         = "org-s3-data-events"
  cloudtrail_is_organization_trail        = true
  cloudtrail_enable_s3_access_logging     = true
  cloudtrail_enforce_ssl                  = true
}
```

### Notes

- The StackSet uses service-managed permissions and targets OUs; enable trusted access for CloudFormation StackSets with AWS Organizations.
- The baseline template conditionally applies IAM Account Password Policy only in us-east-1.
- AWS Support Role is deployed per-account via StackSets for SecurityHub IAM.18 compliance.
- CloudTrail S3 logging addresses multiple SecurityHub controls (S3.22, S3.23, CloudTrail.7, S3.5).
- IAM Access Analyzer is deployed directly in the main module for organization-wide external access detection.
- Centralized Root Access Management removes root credentials from member accounts, addressing SecurityHub IAM.6 control.

### SecurityHub Compliance Coverage

This module addresses the following AWS SecurityHub controls:

| Control | Description | Implementation |
|---------|-------------|----------------|
| **S3.1** | S3 general purpose buckets should block public access | StackSets → S3 Account Public Access Block |
| **S3.5** | S3 buckets should require SSL/HTTPS | CloudTrail S3 bucket policy |
| **S3.22** | S3 buckets should log object-level write events | CloudTrail advanced event selectors |
| **S3.23** | S3 buckets should log object-level read events | CloudTrail advanced event selectors |
| **EC2.7** | EBS default encryption should be enabled | StackSets → EBS encryption by default with optional custom KMS keys |
| **IAM.6** | Hardware MFA should be enabled for the root user | Centralized Root Access Management → Removes root credentials from member accounts |
| **IAM.7** | Password policy should have strong configurations | StackSets → IAM Account Password Policy |
| **IAM.18** | Support role should exist for incident management | StackSets → AWS Support Role |
| **CloudTrail.7** | S3 bucket access logging should be enabled | CloudTrail S3 access logging |

---

<!-- The following section is generated by terraform-docs. Run:
terraform-docs markdown --output-file README.md .
-->


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail_s3_logging"></a> [cloudtrail\_s3\_logging](#module\_cloudtrail\_s3\_logging) | ./modules/cloudtrail-s3-logging | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_accessanalyzer_analyzer.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |
| [aws_accessanalyzer_archive_rule.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_archive_rule) | resource |
| [aws_cloudformation_stack_instances.baseline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_instances) | resource |
| [aws_cloudformation_stack_set.baseline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_iam_organizations_features.centralized_root_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_organizations_features) | resource |
| [null_resource.enable_access_analyzer_service_access](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.enable_cloudformation_org_access](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.enable_iam_org_access](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_analyzer_archive_rules"></a> [access\_analyzer\_archive\_rules](#input\_access\_analyzer\_archive\_rules) | Map of archive rules to create for the analyzer | <pre>map(object({<br/>    filters = list(object({<br/>      criteria = string<br/>      contains = optional(list(string))<br/>      eq       = optional(list(string))<br/>      exists   = optional(string)<br/>      neq      = optional(list(string))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_access_analyzer_name"></a> [access\_analyzer\_name](#input\_access\_analyzer\_name) | n/a | `string` | `"org-external-access"` | no |
| <a name="input_access_analyzer_type"></a> [access\_analyzer\_type](#input\_access\_analyzer\_type) | n/a | `string` | `"ORGANIZATION"` | no |
| <a name="input_access_analyzer_unused_access_configuration"></a> [access\_analyzer\_unused\_access\_configuration](#input\_access\_analyzer\_unused\_access\_configuration) | Configuration for unused access analyzer | <pre>object({<br/>    unused_access_age = number<br/>  })</pre> | `null` | no |
| <a name="input_aws_support_role_max_session_duration"></a> [aws\_support\_role\_max\_session\_duration](#input\_aws\_support\_role\_max\_session\_duration) | Maximum session duration for the AWS Support role in seconds | `number` | `3600` | no |
| <a name="input_aws_support_role_name"></a> [aws\_support\_role\_name](#input\_aws\_support\_role\_name) | Name of the AWS Support role | `string` | `"AWSSupport-IncidentManagement"` | no |
| <a name="input_aws_support_role_require_mfa"></a> [aws\_support\_role\_require\_mfa](#input\_aws\_support\_role\_require\_mfa) | Whether to require MFA for assuming the AWS Support role | `bool` | `true` | no |
| <a name="input_aws_support_trusted_entities"></a> [aws\_support\_trusted\_entities](#input\_aws\_support\_trusted\_entities) | Comma-separated list of trusted entity ARNs allowed to assume the Support role (used when mode is custom) | `string` | `""` | no |
| <a name="input_aws_support_trusted_entities_mode"></a> [aws\_support\_trusted\_entities\_mode](#input\_aws\_support\_trusted\_entities\_mode) | Select who can assume the Support role (root=current account root, custom=provide ARNs) | `string` | `"root"` | no |
| <a name="input_centralized_root_access_features"></a> [centralized\_root\_access\_features](#input\_centralized\_root\_access\_features) | List of centralized root access features to enable. Valid values: RootCredentialsManagement, RootSessions | `list(string)` | <pre>[<br/>  "RootCredentialsManagement",<br/>  "RootSessions"<br/>]</pre> | no |
| <a name="input_cloudtrail_enable_s3_access_logging"></a> [cloudtrail\_enable\_s3\_access\_logging](#input\_cloudtrail\_enable\_s3\_access\_logging) | Whether to enable S3 access logging for SecurityHub CloudTrail.7 compliance | `bool` | `true` | no |
| <a name="input_cloudtrail_enforce_ssl"></a> [cloudtrail\_enforce\_ssl](#input\_cloudtrail\_enforce\_ssl) | Whether to enforce SSL/HTTPS for CloudTrail S3 bucket (SecurityHub S3.5) | `bool` | `true` | no |
| <a name="input_cloudtrail_is_organization_trail"></a> [cloudtrail\_is\_organization\_trail](#input\_cloudtrail\_is\_organization\_trail) | Whether the CloudTrail is an organization trail | `bool` | `true` | no |
| <a name="input_cloudtrail_log_retention_days"></a> [cloudtrail\_log\_retention\_days](#input\_cloudtrail\_log\_retention\_days) | Number of days to retain CloudTrail logs (0 = indefinitely) | `number` | `2555` | no |
| <a name="input_cloudtrail_name"></a> [cloudtrail\_name](#input\_cloudtrail\_name) | Name of the CloudTrail | `string` | `"org-s3-data-events"` | no |
| <a name="input_cloudtrail_s3_bucket_name_prefix"></a> [cloudtrail\_s3\_bucket\_name\_prefix](#input\_cloudtrail\_s3\_bucket\_name\_prefix) | Prefix for CloudTrail S3 bucket name | `string` | `"org-cloudtrail"` | no |
| <a name="input_cloudtrail_s3_buckets_to_monitor"></a> [cloudtrail\_s3\_buckets\_to\_monitor](#input\_cloudtrail\_s3\_buckets\_to\_monitor) | List of S3 bucket ARNs to monitor for data events. Empty list monitors all buckets | `list(string)` | `[]` | no |
| <a name="input_create_access_analyzer"></a> [create\_access\_analyzer](#input\_create\_access\_analyzer) | Access Analyzer | `bool` | `true` | no |
| <a name="input_create_aws_support_role"></a> [create\_aws\_support\_role](#input\_create\_aws\_support\_role) | Whether to create AWS Support role for incident management (per-account) | `bool` | `true` | no |
| <a name="input_create_ebs_kms_key"></a> [create\_ebs\_kms\_key](#input\_create\_ebs\_kms\_key) | Whether to create a dedicated KMS key for EBS encryption | `bool` | `false` | no |
| <a name="input_create_iam_access_analyzer"></a> [create\_iam\_access\_analyzer](#input\_create\_iam\_access\_analyzer) | Whether to create IAM Access Analyzer in each account via StackSets | `bool` | `true` | no |
| <a name="input_create_iam_access_analyzer_archive_rules"></a> [create\_iam\_access\_analyzer\_archive\_rules](#input\_create\_iam\_access\_analyzer\_archive\_rules) | Whether to create default archive rules for the IAM Access Analyzer | `bool` | `false` | no |
| <a name="input_create_password_policy"></a> [create\_password\_policy](#input\_create\_password\_policy) | n/a | `bool` | `true` | no |
| <a name="input_ebs_default_kms_key_id"></a> [ebs\_default\_kms\_key\_id](#input\_ebs\_default\_kms\_key\_id) | ARN of existing KMS key to use for EBS encryption (alternative to creating new key) | `string` | `null` | no |
| <a name="input_ebs_encryption_by_default"></a> [ebs\_encryption\_by\_default](#input\_ebs\_encryption\_by\_default) | n/a | `bool` | `true` | no |
| <a name="input_ebs_kms_key_alias"></a> [ebs\_kms\_key\_alias](#input\_ebs\_kms\_key\_alias) | Alias for the EBS encryption KMS key (must start with 'alias/') | `string` | `"alias/security-baseline-ebs-encryption"` | no |
| <a name="input_ebs_kms_key_deletion_window"></a> [ebs\_kms\_key\_deletion\_window](#input\_ebs\_kms\_key\_deletion\_window) | KMS key deletion window in days | `number` | `7` | no |
| <a name="input_ebs_kms_key_rotation"></a> [ebs\_kms\_key\_rotation](#input\_ebs\_kms\_key\_rotation) | Enable automatic rotation for the EBS encryption KMS key | `bool` | `true` | no |
| <a name="input_enable_centralized_root_access"></a> [enable\_centralized\_root\_access](#input\_enable\_centralized\_root\_access) | Whether to enable centralized root access management for organization member accounts (IAM.6 compliance) | `bool` | `true` | no |
| <a name="input_enable_cloudtrail"></a> [enable\_cloudtrail](#input\_enable\_cloudtrail) | Whether to enable CloudTrail S3 logging for SecurityHub compliance | `bool` | `true` | no |
| <a name="input_enable_stacksets"></a> [enable\_stacksets](#input\_enable\_stacksets) | n/a | `bool` | `true` | no |
| <a name="input_iam_access_analyzer_name"></a> [iam\_access\_analyzer\_name](#input\_iam\_access\_analyzer\_name) | Name of the IAM Access Analyzer to create per account | `string` | `"security-baseline-external-analyzer"` | no |
| <a name="input_iam_access_analyzer_s3_bucket_exclusion"></a> [iam\_access\_analyzer\_s3\_bucket\_exclusion](#input\_iam\_access\_analyzer\_s3\_bucket\_exclusion) | S3 bucket name to exclude from IAM Access Analyzer findings (creates archive rule if provided) | `string` | `""` | no |
| <a name="input_iam_access_analyzer_type"></a> [iam\_access\_analyzer\_type](#input\_iam\_access\_analyzer\_type) | Type of IAM Access Analyzer (ACCOUNT, ORGANIZATION, ORGANIZATION\_UNUSED\_ACCESS) | `string` | `"ACCOUNT"` | no |
| <a name="input_iam_access_analyzer_unused_access_age"></a> [iam\_access\_analyzer\_unused\_access\_age](#input\_iam\_access\_analyzer\_unused\_access\_age) | Number of days to consider access as unused (only for ORGANIZATION\_UNUSED\_ACCESS type) | `number` | `90` | no |
| <a name="input_log_archive_account_id"></a> [log\_archive\_account\_id](#input\_log\_archive\_account\_id) | The AWS account ID of the Log Archive Account where the S3 bucket is located. If not provided, uses the current account | `string` | `null` | no |
| <a name="input_password_allow_users_to_change"></a> [password\_allow\_users\_to\_change](#input\_password\_allow\_users\_to\_change) | n/a | `bool` | `true` | no |
| <a name="input_password_hard_expiry"></a> [password\_hard\_expiry](#input\_password\_hard\_expiry) | n/a | `bool` | `false` | no |
| <a name="input_password_max_age"></a> [password\_max\_age](#input\_password\_max\_age) | n/a | `number` | `90` | no |
| <a name="input_password_min_length"></a> [password\_min\_length](#input\_password\_min\_length) | n/a | `number` | `14` | no |
| <a name="input_password_require_lowercase"></a> [password\_require\_lowercase](#input\_password\_require\_lowercase) | n/a | `bool` | `true` | no |
| <a name="input_password_require_numbers"></a> [password\_require\_numbers](#input\_password\_require\_numbers) | n/a | `bool` | `true` | no |
| <a name="input_password_require_symbols"></a> [password\_require\_symbols](#input\_password\_require\_symbols) | n/a | `bool` | `true` | no |
| <a name="input_password_require_uppercase"></a> [password\_require\_uppercase](#input\_password\_require\_uppercase) | n/a | `bool` | `true` | no |
| <a name="input_password_reuse_prevention"></a> [password\_reuse\_prevention](#input\_password\_reuse\_prevention) | n/a | `number` | `24` | no |
| <a name="input_s3_pab_block_public_acls"></a> [s3\_pab\_block\_public\_acls](#input\_s3\_pab\_block\_public\_acls) | Per-account baseline parameters | `bool` | `true` | no |
| <a name="input_s3_pab_block_public_policy"></a> [s3\_pab\_block\_public\_policy](#input\_s3\_pab\_block\_public\_policy) | n/a | `bool` | `true` | no |
| <a name="input_s3_pab_ignore_public_acls"></a> [s3\_pab\_ignore\_public\_acls](#input\_s3\_pab\_ignore\_public\_acls) | n/a | `bool` | `true` | no |
| <a name="input_s3_pab_restrict_public_buckets"></a> [s3\_pab\_restrict\_public\_buckets](#input\_s3\_pab\_restrict\_public\_buckets) | n/a | `bool` | `true` | no |
| <a name="input_stackset_name"></a> [stackset\_name](#input\_stackset\_name) | StackSets | `string` | `"org-baseline-security"` | no |
| <a name="input_stacksets_organizational_unit_ids"></a> [stacksets\_organizational\_unit\_ids](#input\_stacksets\_organizational\_unit\_ids) | n/a | `list(string)` | `[]` | no |
| <a name="input_stacksets_regions"></a> [stacksets\_regions](#input\_stacksets\_regions) | n/a | `list(string)` | <pre>[<br/>  "us-east-1"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_analyzer_archive_rules"></a> [access\_analyzer\_archive\_rules](#output\_access\_analyzer\_archive\_rules) | Map of Access Analyzer archive rules created |
| <a name="output_access_analyzer_arn"></a> [access\_analyzer\_arn](#output\_access\_analyzer\_arn) | IAM Access Analyzer ARN |
| <a name="output_centralized_root_access_enabled"></a> [centralized\_root\_access\_enabled](#output\_centralized\_root\_access\_enabled) | Whether centralized root access management is enabled |
| <a name="output_centralized_root_access_features"></a> [centralized\_root\_access\_features](#output\_centralized\_root\_access\_features) | List of enabled centralized root access features |
| <a name="output_centralized_root_access_organization_id"></a> [centralized\_root\_access\_organization\_id](#output\_centralized\_root\_access\_organization\_id) | AWS Organization ID where centralized root access is enabled |
| <a name="output_cfn_stackset"></a> [cfn\_stackset](#output\_cfn\_stackset) | CloudFormation StackSet outputs |
| <a name="output_cloudtrail"></a> [cloudtrail](#output\_cloudtrail) | CloudTrail S3 logging submodule outputs |
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | CloudTrail ARN |
| <a name="output_cloudtrail_kms_key_arn"></a> [cloudtrail\_kms\_key\_arn](#output\_cloudtrail\_kms\_key\_arn) | CloudTrail KMS key ARN |
| <a name="output_cloudtrail_s3_bucket_name"></a> [cloudtrail\_s3\_bucket\_name](#output\_cloudtrail\_s3\_bucket\_name) | CloudTrail S3 bucket name |
| <a name="output_compliance_summary"></a> [compliance\_summary](#output\_compliance\_summary) | Summary of compliance controls deployed |
| <a name="output_kms_key_configuration"></a> [kms\_key\_configuration](#output\_kms\_key\_configuration) | KMS key configuration for EBS encryption |
| <a name="output_stackset_name"></a> [stackset\_name](#output\_stackset\_name) | CloudFormation StackSet name for per-account baselines |
<!-- END_TF_DOCS -->