# AWS CloudTrail S3 Logging Terraform Module

This Terraform module creates AWS CloudTrail trails for S3 bucket and object logging, addressing SecurityHub findings **S3.22** and **S3.23** with full AWS Control Tower and Organizations tag policy support.

## Features

- ✅ **SecurityHub S3.22 & S3.23 compliance** - Object read/write event logging
- ✅ **SecurityHub CloudTrail.7 compliance** - S3 bucket access logging enabled
- ✅ **SecurityHub S3.5 compliance** - SSL/HTTPS enforcement for all S3 requests
- ✅ **Multi-region & organization trails** for comprehensive coverage
- ✅ **Control Tower integration** with cross-account S3 bucket support
- ✅ **KMS encryption by default** with automatic key creation
- ✅ **Tag policy compliance** for AWS Organizations
- ✅ **SSO Administrator access** for encrypted log decryption
- ✅ **Configurable bucket filtering** and lifecycle management
- ✅ **S3 access logging** with automatic access logs bucket creation

## Tag Policy Compliance

**Critical**: This module follows AWS Organizations tag policy requirements:

```hcl
# ✅ Compliant tags
tags = {
  account     = "log_archive"        # Lowercase key, standard value
  environment = "production"         # No spaces, standard values
  purpose     = "cloudtrail-logging" # Use hyphens, not spaces
}

# ❌ Will cause tag policy violations
tags = {
  Account = "Log Archive Account"    # Wrong case, spaces in value
}
```

**Supported account values**: `management`, `log_archive`, `audit`, `shared_services`, `security`

## Quick Start

### Basic Usage

```hcl
module "cloudtrail_s3_logging" {
  source = "./modules/aws/terraform-aws-cloudtrail-s3-logging"

  trail_name            = "s3-data-events-trail"
  is_multi_region_trail = true
  
  tags = {
    account     = "log_archive"
    environment = "production"
    purpose     = "securityhub-compliance"
  }
}
```

### Control Tower Setup (Recommended)

```hcl
# Configure providers
provider "aws" {
  region = "us-east-1"
  # Management Account (default)
}

provider "aws" {
  alias  = "log_archive"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.log_archive_account_id}:role/OrganizationAccountAccessRole"
  }
}

# Deploy module
module "cloudtrail_control_tower" {
  source = "./modules/aws/terraform-aws-cloudtrail-s3-logging"

  providers = {
    aws.log_archive = aws.log_archive
  }

  trail_name             = "control-tower-s3-events"
  log_archive_account_id = var.log_archive_account_id
  management_account_id  = var.management_account_id
  
  # Organization trail for all accounts
  is_organization_trail = true
  is_multi_region_trail = true
  
  # S3 bucket in Log Archive Account
  s3_bucket_name_prefix = "ct-cloudtrail-logs"
  s3_key_prefix        = "s3-events/"
  
  tags = {
    account     = "log_archive"
    environment = "control-tower"
    purpose     = "organization-s3-compliance"
  }
}
```

### Monitor Specific Buckets

```hcl
module "cloudtrail_targeted" {
  source = "./modules/aws/terraform-aws-cloudtrail-s3-logging"

  trail_name = "targeted-monitoring"
  
  # Only monitor specific buckets
  s3_buckets_to_monitor = [
    "arn:aws:s3:::my-app-data",
    "arn:aws:s3:::user-uploads"
  ]
  
  # Exclude CloudTrail bucket to avoid circular logging
  s3_buckets_to_exclude = [
    "arn:aws:s3:::cloudtrail-logs-bucket"
  ]
  
  enable_cloudwatch_logs = true
  
  # Enable S3 access logging (SecurityHub CloudTrail.7)
  enable_s3_access_logging = true
  
  # Enforce SSL/HTTPS (SecurityHub S3.5)
  enforce_ssl = true
  access_logs_enforce_ssl = true
  
  tags = {
    account = "management"
    environment = "production"
    purpose = "targeted-monitoring"
  }
}
```

### S3 Access Logging (SecurityHub CloudTrail.7)

```hcl
module "cloudtrail_with_access_logging" {
  source = "./modules/aws/terraform-aws-cloudtrail-s3-logging"

  trail_name = "cloudtrail-with-access-logs"
  s3_bucket_name_prefix = "my-org-s3-objects"  # Used for both CloudTrail and access logs buckets
  
  # Enable S3 access logging (SecurityHub CloudTrail.7)
  enable_s3_access_logging         = true
  create_access_logs_bucket        = true
  access_logs_target_prefix        = "cloudtrail-access-logs/"
  access_logs_retention_days       = 90
  
  # Custom access logs bucket configuration
  access_logs_bucket_lifecycle_enabled = true
  access_logs_bucket_force_destroy     = false
  
  # SSL enforcement (SecurityHub S3.5)
  enforce_ssl = true
  access_logs_enforce_ssl = true
  
  tags = {
    account     = "log_archive"
    environment = "production"
    purpose     = "cloudtrail-access-logging"
  }
}

# This creates buckets with consistent naming:
# CloudTrail bucket: my-org-s3-objects-cloudtrail-logs-123456789012-ra1k
# Access logs bucket: my-org-s3-objects-cloudtrail-access-logs-123456789012-ra1k

### SSL/HTTPS Enforcement (SecurityHub S3.5)

```hcl
module "cloudtrail_ssl_enforced" {
  source = "./modules/aws/terraform-aws-cloudtrail-s3-logging"

  trail_name = "cloudtrail-ssl-enforced"
  
  # Enforce SSL/HTTPS for all S3 requests (SecurityHub S3.5)
  enforce_ssl = true
  access_logs_enforce_ssl = true
  
  # This configuration denies all requests that don't use HTTPS
  # Applies to both CloudTrail bucket and access logs bucket
  
  tags = {
    account     = "log_archive"
    environment = "production"
    purpose     = "ssl-secured-logging"
  }
}
```

## Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `trail_name` | CloudTrail name | auto-generated |
| `log_archive_account_id` | Log Archive Account ID (Control Tower) | current account |
| `management_account_id` | Management Account ID (Control Tower) | current account |
| `is_organization_trail` | Create organization trail | `false` |
| `is_multi_region_trail` | Multi-region coverage | `true` |
| `create_kms_key` | Create dedicated KMS key | `true` |
| `s3_buckets_to_monitor` | Specific buckets to monitor | `[]` (all) |
| `s3_buckets_to_exclude` | Buckets to exclude | `[]` |
| `enable_cloudwatch_logs` | CloudWatch Logs integration | `false` |
| `enable_s3_access_logging` | Enable S3 access logging (CloudTrail.7) | `true` |
| `create_access_logs_bucket` | Create separate access logs bucket | `true` |
| `access_logs_retention_days` | Access logs retention period | `90` |
| `enforce_ssl` | Enforce SSL/HTTPS for CloudTrail bucket (S3.5) | `true` |
| `access_logs_enforce_ssl` | Enforce SSL/HTTPS for access logs bucket (S3.5) | `true` |

**Note**: The access logs bucket uses the same `s3_bucket_name_prefix` as the CloudTrail bucket but with "cloudtrail-access-logs" instead of "cloudtrail-logs" in the name.
| `tags` | Resource tags | `{}` |

[Full variable list in source code]

### Key Outputs

| Output | Description |
|--------|-------------|
| `cloudtrail_arn` | CloudTrail ARN |
| `s3_bucket_name` | S3 bucket name |
| `kms_key_arn` | KMS key ARN |
| `sso_admin_role_arns` | SSO roles with decrypt access |
| `s3_access_logging_enabled` | Whether S3 access logging is enabled |
| `access_logs_bucket_name` | Access logs S3 bucket name |
| `access_logs_bucket_arn` | Access logs S3 bucket ARN |
| `s3_ssl_enforcement_enabled` | Whether SSL enforcement is enabled on CloudTrail bucket |
| `access_logs_ssl_enforcement_enabled` | Whether SSL enforcement is enabled on access logs bucket |

## Bucket Naming Convention

The module creates S3 buckets with consistent naming patterns:

### CloudTrail Logs Bucket
- **With prefix**: `{s3_bucket_name_prefix}-cloudtrail-logs-{account_id}-{random_suffix}`
- **Without prefix**: `cloudtrail-logs-{account_id}-{random_suffix}`
- **Example**: `s3-objects-cloudtrail-logs-891377156525-ra1k`

### Access Logs Bucket
- **With prefix**: `{s3_bucket_name_prefix}-cloudtrail-access-logs-{account_id}-{random_suffix}`
- **Without prefix**: `cloudtrail-access-logs-{account_id}-{random_suffix}`  
- **Example**: `s3-objects-cloudtrail-access-logs-891377156525-ra1k`

Both buckets use the same `s3_bucket_name_prefix` variable to ensure consistent naming across your infrastructure.

## Architecture

**Control Tower Multi-Account:**
```
Management Account          Log Archive Account
├── CloudTrail Trail   ──→  ├── S3 Bucket (encrypted)
├── KMS Key                 ├── Lifecycle Policies  
├── CloudWatch Logs         └── SSO Admin Access
└── IAM Policies
```

**Security Features:**
- KMS encryption with automatic rotation
- Cross-account IAM policies  
- SSO Administrator decrypt permissions
- S3 versioning and public access blocking
- Log file validation

## SecurityHub Compliance

**S3.22**: Logs object-level **write** events (PutObject, DeleteObject, etc.)
**S3.23**: Logs object-level **read** events (GetObject, HeadObject, etc.)
**CloudTrail.7**: Enables S3 bucket access logging on the CloudTrail S3 bucket
**S3.5**: Enforces SSL/HTTPS for all requests to S3 buckets (denies insecure HTTP)

Uses advanced event selectors for precise S3 data event filtering, automatic S3 access logging, and SSL enforcement via bucket policies.

## Troubleshooting

### Tag Policy Violations

```bash
# Error: "For 'account', use the capitalization specified by the tag policy"

# Fix: Use lowercase keys and standard values
tags = {
  account = "log_archive"  # not "Account" or "Log Archive Account"
}
```

### Common Issues

1. **CloudTrail can't write to S3**: Check bucket policy and cross-account permissions
2. **KMS decrypt errors**: Verify SSO roles have proper permissions via `kms:ViaService`
3. **Missing events**: Check event selectors and bucket inclusion/exclusion lists
4. **Provider errors**: Ensure log_archive provider is correctly configured

### Debug Commands

```bash
# Test S3 events
aws s3 cp file.txt s3://test-bucket/file.txt
aws logs describe-log-streams --log-group-name "/aws/cloudtrail/trail-name"

# Verify KMS access
aws kms describe-key --key-id alias/cloudtrail-key
```

## Cost Optimization

- **Lifecycle policies**: Standard-IA (60d) → Glacier (180d) → Deep Archive (365d)
- **Bucket filtering**: Monitor only necessary buckets
- **Organization trails**: Single trail for all accounts
- **Log retention**: Configure with `log_retention_days`

## Best Practices

1. **Use organization trails** for enterprise compliance
2. **Enable KMS encryption** with automatic rotation
3. **Follow tag policies** with lowercase keys and standard values
4. **Monitor costs** regularly with AWS Cost Explorer
5. **Enable log file validation** for tamper detection

## Requirements

- **Control Tower**: Deploy from Management Account with Log Archive provider
- **Organizations**: Must be part of AWS Organizations for organization trails
- **Permissions**: Cross-account roles (OrganizationAccountAccessRole or AWSControlTowerExecution)
- **Providers**: Two AWS providers required for cross-account setup

## Support

- [AWS CloudTrail Documentation](https://docs.aws.amazon.com/cloudtrail/)
- [SecurityHub S3 Controls](https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html)
- [AWS Organizations Tag Policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies.html)


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
| <a name="provider_aws.log_archive"></a> [aws.log\_archive](#provider\_aws.log\_archive) | >= 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [random_string.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.log_archive](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.access_logs_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_roles.sso_admin_log_archive](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_bucket_force_destroy"></a> [access\_logs\_bucket\_force\_destroy](#input\_access\_logs\_bucket\_force\_destroy) | Whether to force destroy the access logs S3 bucket (allows deletion of non-empty bucket) | `bool` | `false` | no |
| <a name="input_access_logs_bucket_lifecycle_enabled"></a> [access\_logs\_bucket\_lifecycle\_enabled](#input\_access\_logs\_bucket\_lifecycle\_enabled) | Whether to enable lifecycle configuration for access logs bucket | `bool` | `true` | no |
| <a name="input_access_logs_bucket_name"></a> [access\_logs\_bucket\_name](#input\_access\_logs\_bucket\_name) | The name of the S3 bucket for access logs. If not provided and create\_access\_logs\_bucket is true, a bucket will be created | `string` | `null` | no |
| <a name="input_access_logs_enforce_ssl"></a> [access\_logs\_enforce\_ssl](#input\_access\_logs\_enforce\_ssl) | Whether to enforce SSL/HTTPS for all requests to the access logs S3 bucket (SecurityHub S3.5) | `bool` | `true` | no |
| <a name="input_access_logs_retention_days"></a> [access\_logs\_retention\_days](#input\_access\_logs\_retention\_days) | Number of days to retain access logs before deletion. If null, logs are retained indefinitely | `number` | `90` | no |
| <a name="input_access_logs_target_prefix"></a> [access\_logs\_target\_prefix](#input\_access\_logs\_target\_prefix) | The prefix for access log objects | `string` | `"access-logs/"` | no |
| <a name="input_cloudwatch_logs_kms_key_id"></a> [cloudwatch\_logs\_kms\_key\_id](#input\_cloudwatch\_logs\_kms\_key\_id) | The KMS key ID to use for encrypting CloudWatch logs. If not provided, defaults to the CloudTrail KMS key if created, otherwise uses CloudWatch default encryption | `string` | `null` | no |
| <a name="input_cloudwatch_logs_retention_in_days"></a> [cloudwatch\_logs\_retention\_in\_days](#input\_cloudwatch\_logs\_retention\_in\_days) | The number of days to retain CloudWatch logs | `number` | `30` | no |
| <a name="input_create_access_logs_bucket"></a> [create\_access\_logs\_bucket](#input\_create\_access\_logs\_bucket) | Whether to create a separate S3 bucket for access logs. If false, you must provide access\_logs\_bucket\_name | `bool` | `true` | no |
| <a name="input_create_cloudtrail"></a> [create\_cloudtrail](#input\_create\_cloudtrail) | Whether to create the CloudTrail | `bool` | `true` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Whether to create a dedicated KMS key for CloudTrail log encryption. If true, creates a new key. If false, uses the provided kms\_key\_id or defaults to S3 managed encryption | `bool` | `true` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Whether to create the S3 bucket for CloudTrail logs | `bool` | `true` | no |
| <a name="input_create_s3_bucket_policy"></a> [create\_s3\_bucket\_policy](#input\_create\_s3\_bucket\_policy) | Whether to create the S3 bucket policy for CloudTrail | `bool` | `true` | no |
| <a name="input_enable_cloudwatch_logs"></a> [enable\_cloudwatch\_logs](#input\_enable\_cloudwatch\_logs) | Whether to enable CloudWatch Logs for CloudTrail | `bool` | `false` | no |
| <a name="input_enable_lifecycle_configuration"></a> [enable\_lifecycle\_configuration](#input\_enable\_lifecycle\_configuration) | Whether to enable S3 lifecycle configuration for CloudTrail logs | `bool` | `true` | no |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation) | Whether to enable log file integrity validation | `bool` | `true` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether to enable logging for the trail | `bool` | `true` | no |
| <a name="input_enable_s3_access_logging"></a> [enable\_s3\_access\_logging](#input\_enable\_s3\_access\_logging) | Whether to enable S3 access logging on the CloudTrail S3 bucket (SecurityHub CloudTrail.7) | `bool` | `true` | no |
| <a name="input_enforce_ssl"></a> [enforce\_ssl](#input\_enforce\_ssl) | Whether to enforce SSL/HTTPS for all requests to the CloudTrail S3 bucket (SecurityHub S3.5) | `bool` | `true` | no |
| <a name="input_force_destroy_s3_bucket"></a> [force\_destroy\_s3\_bucket](#input\_force\_destroy\_s3\_bucket) | Whether to force destroy the S3 bucket (allows deletion of non-empty bucket) | `bool` | `false` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Whether to include events from global services such as IAM | `bool` | `true` | no |
| <a name="input_include_management_events"></a> [include\_management\_events](#input\_include\_management\_events) | Whether to include management events in addition to S3 data events | `bool` | `false` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | Whether the trail is created in the current region or in all regions | `bool` | `true` | no |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail) | Whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account | `bool` | `true` | no |
| <a name="input_kms_key_alias"></a> [kms\_key\_alias](#input\_kms\_key\_alias) | The alias for the KMS key. Only used when create\_kms\_key is true | `string` | `null` | no |
| <a name="input_kms_key_deletion_window"></a> [kms\_key\_deletion\_window](#input\_kms\_key\_deletion\_window) | The number of days after which the KMS key will be deleted when destroyed. Must be between 7 and 30 days | `number` | `30` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS key ID/ARN to use for encrypting CloudTrail logs. If not provided and create\_kms\_key is true, a new key will be created. If not provided and create\_kms\_key is false, S3 managed encryption (AES256) will be used | `string` | `null` | no |
| <a name="input_kms_key_rotation"></a> [kms\_key\_rotation](#input\_kms\_key\_rotation) | Whether to enable automatic key rotation for the created KMS key | `bool` | `true` | no |
| <a name="input_log_archive_account_id"></a> [log\_archive\_account\_id](#input\_log\_archive\_account\_id) | The AWS account ID of the Log Archive Account where the S3 bucket is located. If not provided, uses the current account | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain CloudTrail logs before deletion. If null, logs are retained indefinitely | `number` | `null` | no |
| <a name="input_management_account_id"></a> [management\_account\_id](#input\_management\_account\_id) | The AWS account ID of the Management Account where the CloudTrail is created. If not provided, uses the current account | `string` | `null` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket for CloudTrail logs. If not provided, a bucket will be created | `string` | `null` | no |
| <a name="input_s3_bucket_name_prefix"></a> [s3\_bucket\_name\_prefix](#input\_s3\_bucket\_name\_prefix) | The prefix to use for the S3 bucket name when creating a new bucket | `string` | `"s3-objects"` | no |
| <a name="input_s3_buckets_to_exclude"></a> [s3\_buckets\_to\_exclude](#input\_s3\_buckets\_to\_exclude) | List of S3 bucket ARNs to exclude from monitoring | `list(string)` | `[]` | no |
| <a name="input_s3_buckets_to_monitor"></a> [s3\_buckets\_to\_monitor](#input\_s3\_buckets\_to\_monitor) | List of S3 bucket ARNs to monitor for data events. If empty, all S3 buckets will be monitored | `list(string)` | `[]` | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The prefix for the location in the S3 bucket | `string` | `""` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | The name of the SNS topic for CloudTrail notifications | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_trail_name"></a> [trail\_name](#input\_trail\_name) | The name of the CloudTrail | `string` | `"S3-Object-Logs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_logs_bucket_arn"></a> [access\_logs\_bucket\_arn](#output\_access\_logs\_bucket\_arn) | The ARN of the S3 bucket used for access logs |
| <a name="output_access_logs_bucket_created"></a> [access\_logs\_bucket\_created](#output\_access\_logs\_bucket\_created) | Whether a new access logs bucket was created by this module |
| <a name="output_access_logs_bucket_id"></a> [access\_logs\_bucket\_id](#output\_access\_logs\_bucket\_id) | The ID of the S3 bucket used for access logs |
| <a name="output_access_logs_bucket_name"></a> [access\_logs\_bucket\_name](#output\_access\_logs\_bucket\_name) | The name of the S3 bucket used for access logs |
| <a name="output_access_logs_ssl_enforcement_enabled"></a> [access\_logs\_ssl\_enforcement\_enabled](#output\_access\_logs\_ssl\_enforcement\_enabled) | Whether SSL enforcement is enabled on the access logs S3 bucket (SecurityHub S3.5) |
| <a name="output_access_logs_target_prefix"></a> [access\_logs\_target\_prefix](#output\_access\_logs\_target\_prefix) | The prefix for access log objects |
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | The ARN of the CloudTrail |
| <a name="output_cloudtrail_home_region"></a> [cloudtrail\_home\_region](#output\_cloudtrail\_home\_region) | The home region of the CloudTrail |
| <a name="output_cloudtrail_id"></a> [cloudtrail\_id](#output\_cloudtrail\_id) | The ID of the CloudTrail |
| <a name="output_cloudtrail_name"></a> [cloudtrail\_name](#output\_cloudtrail\_name) | The name of the CloudTrail |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | The ARN of the CloudWatch log group for CloudTrail logs |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | The name of the CloudWatch log group for CloudTrail logs |
| <a name="output_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#output\_cloudwatch\_log\_group\_retention\_in\_days) | The retention period of the CloudWatch log group for CloudTrail logs |
| <a name="output_cloudwatch_logs_kms_encrypted"></a> [cloudwatch\_logs\_kms\_encrypted](#output\_cloudwatch\_logs\_kms\_encrypted) | Whether CloudWatch logs are encrypted with KMS |
| <a name="output_cloudwatch_logs_role_arn"></a> [cloudwatch\_logs\_role\_arn](#output\_cloudwatch\_logs\_role\_arn) | The ARN of the IAM role for CloudWatch Logs delivery |
| <a name="output_cloudwatch_logs_role_name"></a> [cloudwatch\_logs\_role\_name](#output\_cloudwatch\_logs\_role\_name) | The name of the IAM role for CloudWatch Logs delivery |
| <a name="output_current_account_id"></a> [current\_account\_id](#output\_current\_account\_id) | The current AWS account ID where the module is deployed |
| <a name="output_is_cross_account_setup"></a> [is\_cross\_account\_setup](#output\_is\_cross\_account\_setup) | Whether this is a cross-account setup (CloudTrail and S3 bucket in different accounts) |
| <a name="output_kms_key_alias"></a> [kms\_key\_alias](#output\_kms\_key\_alias) | The alias of the KMS key used for CloudTrail log encryption |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key used for CloudTrail log encryption |
| <a name="output_kms_key_created"></a> [kms\_key\_created](#output\_kms\_key\_created) | Whether a new KMS key was created by this module |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The ID of the KMS key used for CloudTrail log encryption |
| <a name="output_log_archive_account_id"></a> [log\_archive\_account\_id](#output\_log\_archive\_account\_id) | The AWS account ID where the S3 bucket is located (Log Archive Account) |
| <a name="output_management_account_id"></a> [management\_account\_id](#output\_management\_account\_id) | The AWS account ID where the CloudTrail is created (Management Account) |
| <a name="output_s3_access_logging_enabled"></a> [s3\_access\_logging\_enabled](#output\_s3\_access\_logging\_enabled) | Whether S3 access logging is enabled on the CloudTrail bucket |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket used for CloudTrail logs |
| <a name="output_s3_bucket_domain_name"></a> [s3\_bucket\_domain\_name](#output\_s3\_bucket\_domain\_name) | The domain name of the S3 bucket used for CloudTrail logs |
| <a name="output_s3_bucket_hosted_zone_id"></a> [s3\_bucket\_hosted\_zone\_id](#output\_s3\_bucket\_hosted\_zone\_id) | The hosted zone ID of the S3 bucket used for CloudTrail logs |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The ID of the S3 bucket used for CloudTrail logs |
| <a name="output_s3_bucket_kms_encrypted"></a> [s3\_bucket\_kms\_encrypted](#output\_s3\_bucket\_kms\_encrypted) | Whether the S3 bucket is encrypted with KMS |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | The name of the S3 bucket used for CloudTrail logs |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The region of the S3 bucket used for CloudTrail logs |
| <a name="output_s3_bucket_regional_domain_name"></a> [s3\_bucket\_regional\_domain\_name](#output\_s3\_bucket\_regional\_domain\_name) | The regional domain name of the S3 bucket used for CloudTrail logs |
| <a name="output_s3_ssl_enforcement_enabled"></a> [s3\_ssl\_enforcement\_enabled](#output\_s3\_ssl\_enforcement\_enabled) | Whether SSL enforcement is enabled on the CloudTrail S3 bucket (SecurityHub S3.5) |
| <a name="output_sso_admin_role_arns"></a> [sso\_admin\_role\_arns](#output\_sso\_admin\_role\_arns) | List of SSO Administrator role ARNs granted decrypt permissions on the KMS key |
| <a name="output_sso_admin_roles_found"></a> [sso\_admin\_roles\_found](#output\_sso\_admin\_roles\_found) | Number of SSO Administrator roles found in the Log Archive Account |
<!-- END_TF_DOCS -->