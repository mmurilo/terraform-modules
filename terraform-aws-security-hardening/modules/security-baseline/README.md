# AWS Security Baseline Terraform Module

This Terraform module implements fundamental AWS Security Hub controls for comprehensive account-level security hardening. It combines essential security configurations including IAM password policies, AWS Support role creation, S3 public access restrictions, and EBS default encryption.

## Security Controls Addressed

This module addresses the following AWS Security Hub controls:

### IAM Security Controls (IAM.7, IAM.11-18, IAM.28)

- **[IAM.7]** Password policies for IAM users should have strong configurations
- **[IAM.11]** Ensure IAM password policy requires at least one uppercase letter
- **[IAM.12]** Ensure IAM password policy requires at least one lowercase letter  
- **[IAM.13]** Ensure IAM password policy requires at least one symbol
- **[IAM.14]** Ensure IAM password policy requires at least one number
- **[IAM.15]** Ensure IAM password policy requires minimum length of 14 or greater
- **[IAM.16]** Ensure IAM password policy prevents password reuse
- **[IAM.17]** Ensure IAM password policy expires passwords within 90 days or less
- **[IAM.18]** Ensure a support role has been created to manage incidents with AWS Support
- **[IAM.28]** IAM Access Analyzer external access analyzer should be enabled

### Storage & Compute Security Controls

- **[S3.1]** S3 general purpose buckets should have block public access settings enabled
- **[EC2.7]** EBS default encryption should be enabled

## Features

- ✅ **IAM Password Policy**: Enforces strong password requirements with configurable complexity rules
- ✅ **AWS Support Role**: Creates IAM role with AWSSupportAccess for incident management
- ✅ **IAM Access Analyzer**: Enables external access analyzer for unintended resource sharing detection
- ✅ **S3 Public Access Block**: Account-level protection against public S3 access
- ✅ **EBS Default Encryption**: Enables encryption by default for all new EBS volumes
- ✅ **Optional KMS Key**: Creates dedicated KMS key for EBS encryption with proper policies
- ✅ **Comprehensive Validation**: Input validation for all parameters
- ✅ **Compliance Reporting**: Detailed compliance status outputs for all controls
- ✅ **Secure Defaults**: Security best practices built into default configurations

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS Account Security Baseline                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   IAM Controls  │  │  Storage & Data │  │  Access Control │  │
│  │(IAM.7-18,IAM.28)│  │   (S3.1, EC2.7)│  │   & Support     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│           │                       │                       │     │
│           ▼                       ▼                       ▼     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ Password Policy │  │ S3 Public Block │  │ Support Role    │  │
│  │ • Min Length 14 │  │ • Block ACLs    │  │ • AWS Support   │  │
│  │ • Complexity    │  │ • Block Policies│  │ • MFA Required  │  │
│  │ • Reuse Prevent │  │ • Ignore ACLs   │  │ • Trusted       │  │
│  │ • Expiration    │  │ • Restrict      │  │   Entities      │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│           │                       │                             │
│           ▼                       ▼                             │
│  ┌─────────────────┐  ┌─────────────────┐                       │
│  │ Access Analyzer │  │ EBS Encryption  │                       │
│  │ • External Type │  │ • Default On    │                       │
│  │ • Unintended    │  │ • KMS Key       │                       │
│  │   Access        │  │ • Auto Rotation │                       │
│  │ • Per-Region    │  │                 │                       │
│  └─────────────────┘  └─────────────────┘                       │
└─────────────────────────────────────────────────────────────────┘
```

## Usage

### Basic Usage (Recommended)

```hcl
module "security_baseline" {
  source = "./modules/security-baseline"

  # Enable all controls with secure defaults
  enable_iam_password_policy            = true
  enable_aws_support_role               = true
  enable_iam_access_analyzer            = true
  enable_s3_account_public_access_block = true
  enable_ebs_encryption_by_default      = true

  # Configure AWS Support role trusted entities
  aws_support_role_trusted_entities = [
    "arn:aws:iam::123456789012:root",
    "arn:aws:iam::123456789012:role/SecurityAdministrator"
  ]

  tags = {
    Environment = "production"
    Owner       = "security-team"
    Purpose     = "SecurityHub compliance"
  }
}
```

### Advanced Configuration

```hcl
module "security_baseline" {
  source = "./modules/security-baseline"

  # IAM Password Policy Settings (IAM.7, IAM.11-17)
  enable_iam_password_policy     = true
  minimum_password_length        = 16
  password_reuse_prevention      = 10
  max_password_age              = 60
  require_lowercase_characters  = true
  require_uppercase_characters  = true
  require_numbers               = true
  require_symbols               = true
  allow_users_to_change_password = true
  hard_expiry                   = false

  # AWS Support Role Settings (IAM.18)
  enable_aws_support_role              = true
  aws_support_role_name                = "CustomSupportRole"
  aws_support_role_path                = "/security/"
  aws_support_role_max_session_duration = 7200  # 2 hours
  aws_support_role_require_mfa         = true
  aws_support_role_trusted_entities    = [
    "arn:aws:iam::123456789012:role/SecurityTeam",
    "arn:aws:iam::987654321098:user/support-admin"
  ]

  # IAM Access Analyzer Settings (IAM.28)
  enable_iam_access_analyzer = true
  iam_access_analyzer_name   = "security-baseline-analyzer"
  iam_access_analyzer_type   = "ACCOUNT"  # or "ORGANIZATION", "ORGANIZATION_UNUSED_ACCESS"
  
  # Optional: Archive Rules for automated finding archival
  iam_access_analyzer_archive_rules = {
    s3_bucket_exclusion = {
      filters = [
        {
          criteria = "resourceType"
          eq       = ["AWS::S3::Bucket"]
        },
        {
          criteria = "resource"
          contains = ["my-public-bucket"]
        }
      ]
    }
  }
  
  # Optional: Unused Access Configuration (only for ORGANIZATION_UNUSED_ACCESS type)
  # iam_access_analyzer_unused_access_configuration = {
  #   unused_access_age = 180
  #   analysis_rule = {
  #     exclusion = [
  #       {
  #         account_ids = ["123456789012"]
  #         resource_tags = [
  #           {
  #             Environment = "production"
  #             Project     = "critical"
  #           }
  #         ]
  #       }
  #     ]
  #   }
  # }

  # S3 Settings (S3.1) - All defaults to true for maximum security
  enable_s3_account_public_access_block = true
  s3_block_public_acls                 = true
  s3_block_public_policy               = true
  s3_ignore_public_acls                = true
  s3_restrict_public_buckets           = true

  # EBS Settings (EC2.7) with custom KMS key
  enable_ebs_encryption_by_default = true
  ebs_encryption_enabled           = true
  create_ebs_kms_key              = true
  ebs_kms_key_alias               = "alias/my-ebs-encryption-key"
  ebs_kms_key_rotation            = true

  tags = {
    Environment = "production"
    Owner       = "security-team"
    Purpose     = "SecurityHub compliance"
    Project     = "security-hardening"
  }
}
```

### IAM Access Analyzer Configuration Options

#### Analyzer Types

⚠️ **Important for SecurityHub IAM.28 Compliance**: Only `ACCOUNT` and `ORGANIZATION` analyzer types satisfy the SecurityHub IAM.28 control requirement for external access analyzers.

The module supports three types of IAM Access Analyzers:

- **`ACCOUNT`** (default): External access analyzer for your account ✅ *IAM.28 compliant*
- **`ORGANIZATION`**: External access analyzer for your organization ✅ *IAM.28 compliant*
- **`ORGANIZATION_UNUSED_ACCESS`**: Unused access analyzer ❌ *NOT IAM.28 compliant*

#### Archive Rules

Archive rules automatically archive findings that match specific criteria, reducing noise:

```hcl
module "security_baseline" {
  source = "./modules/security-baseline"

  # Enable IAM Access Analyzer with archive rules
  enable_iam_access_analyzer = true
  iam_access_analyzer_type   = "ACCOUNT"
  
  iam_access_analyzer_archive_rules = {
    # Archive findings for known public buckets
    public_website_bucket = {
      filters = [
        {
          criteria = "resourceType"
          eq       = ["AWS::S3::Bucket"]
        },
        {
          criteria = "resource"
          contains = ["website-bucket"]
        }
      ]
    }
    
    # Archive cross-account access to specific role
    trusted_role_access = {
      filters = [
        {
          criteria = "principal.aws"
          eq       = ["arn:aws:iam::123456789012:role/TrustedRole"]
        }
      ]
    }
  }
}
```

#### Unused Access Configuration

For organization-wide unused access analysis:

```hcl
module "security_baseline" {
  source = "./modules/security-baseline"

  # Enable unused access analyzer
  iam_access_analyzer_type = "ORGANIZATION_UNUSED_ACCESS"
  
  iam_access_analyzer_unused_access_configuration = {
    unused_access_age = 180  # Consider access unused after 180 days
    analysis_rule = {
      exclusion = [
        {
          # Exclude specific accounts from analysis
          account_ids = ["123456789012", "234567890123"]
        },
        {
          # Exclude resources with specific tags
          resource_tags = [
            {
              Environment = "sandbox"
              Project     = "testing"
            }
          ]
        }
      ]
    }
  }
}
```

### Using Existing KMS Key for EBS Encryption

```hcl
# Reference existing KMS key
data "aws_kms_key" "existing" {
  key_id = "alias/my-existing-key"
}

module "security_baseline" {
  source = "./modules/security-baseline"

  enable_iam_password_policy            = true
  enable_aws_support_role               = true
  enable_s3_account_public_access_block = true
  enable_ebs_encryption_by_default      = true
  
  # Use existing KMS key for EBS encryption
  ebs_kms_key_arn = data.aws_kms_key.existing.arn

  aws_support_role_trusted_entities = [
    "arn:aws:iam::123456789012:root"
  ]

  tags = {
    Environment = "production"
  }
}
```

### Selective Control Enablement

```hcl
# Enable only specific controls
module "security_baseline_selective" {
  source = "./modules/security-baseline"

  # Enable only IAM controls
  enable_iam_password_policy            = true
  enable_aws_support_role               = true
  enable_s3_account_public_access_block = false
  enable_ebs_encryption_by_default      = false

  # Strict password requirements
  minimum_password_length   = 20
  password_reuse_prevention = 24
  max_password_age         = 30
  hard_expiry              = true

  aws_support_role_trusted_entities = [
    "arn:aws:iam::123456789012:role/SecurityAdministrator"
  ]

  tags = {
    Environment = "development"
    Scope       = "iam-only"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_role.aws_support_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.aws_support_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_account_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |
| [aws_ebs_encryption_by_default.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_ebs_default_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_default_kms_key) | resource |
| [aws_kms_key.ebs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_alias.ebs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

### General Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | A map of tags to apply to all resources | `map(string)` | `{}` | no |

### IAM Password Policy Variables (IAM.7, IAM.11-17)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_iam_password_policy | Whether to create the IAM password policy | `bool` | `true` | no |
| minimum_password_length | Minimum length to require for IAM user passwords | `number` | `14` | no |
| require_lowercase_characters | Whether to require lowercase characters for IAM user passwords | `bool` | `true` | no |
| require_numbers | Whether to require numbers for IAM user passwords | `bool` | `true` | no |
| require_uppercase_characters | Whether to require uppercase characters for IAM user passwords | `bool` | `true` | no |
| require_symbols | Whether to require symbols for IAM user passwords | `bool` | `true` | no |
| allow_users_to_change_password | Whether to allow users to change their own password | `bool` | `true` | no |
| hard_expiry | Whether users are prevented from setting a new password after their password has expired | `bool` | `false` | no |
| max_password_age | The number of days that an IAM user password is valid | `number` | `90` | no |
| password_reuse_prevention | The number of previous passwords that users are prevented from reusing | `number` | `24` | no |

### AWS Support Role Variables (IAM.18)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_aws_support_role | Whether to create an AWS Support role for incident management | `bool` | `true` | no |
| aws_support_role_name | The name of the AWS Support role | `string` | `"AWSSupport-IncidentManagement"` | no |
| aws_support_role_path | The path for the AWS Support role | `string` | `"/"` | no |
| aws_support_role_max_session_duration | Maximum session duration (in seconds) for the AWS Support role | `number` | `3600` | no |
| aws_support_role_trusted_entities | List of AWS account ARNs or IAM user/role ARNs that can assume the AWS Support role | `list(string)` | `[]` | no |
| aws_support_role_require_mfa | Whether to require MFA for assuming the AWS Support role | `bool` | `true` | no |
| aws_support_role_tags | A map of tags to apply to the AWS Support role | `map(string)` | See defaults | no |

### S3 Public Access Block Variables (S3.1)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_s3_account_public_access_block | Whether to enable S3 account public access block configuration | `bool` | `true` | no |
| s3_block_public_acls | Whether Amazon S3 should block public ACLs for buckets in this account | `bool` | `true` | no |
| s3_block_public_policy | Whether Amazon S3 should block public bucket policies for buckets in this account | `bool` | `true` | no |
| s3_ignore_public_acls | Whether Amazon S3 should ignore public ACLs for buckets in this account | `bool` | `true` | no |
| s3_restrict_public_buckets | Whether Amazon S3 should restrict public bucket policies for buckets in this account | `bool` | `true` | no |

### EBS Encryption Variables (EC2.7)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_ebs_encryption_by_default | Whether to enable EBS encryption by default | `bool` | `true` | no |
| ebs_encryption_enabled | Whether or not default EBS encryption is enabled | `bool` | `true` | no |
| ebs_kms_key_arn | The ARN of the AWS KMS key to use for EBS encryption | `string` | `null` | no |
| create_ebs_kms_key | Whether to create a dedicated KMS key for EBS encryption | `bool` | `false` | no |
| ebs_kms_key_deletion_window | Duration in days after which the key is deleted after destruction | `number` | `7` | no |
| ebs_kms_key_rotation | Whether to enable automatic rotation of the KMS key | `bool` | `true` | no |
| ebs_kms_key_alias | The alias name for the EBS KMS key | `string` | `"alias/security-baseline-ebs-encryption"` | no |

## Outputs

### IAM Password Policy Outputs

| Name | Description |
|------|-------------|
| iam_password_policy_enabled | Whether IAM password policy is enabled |
| password_policy_arn | The ARN of the IAM password policy |
| minimum_password_length | Minimum length to require for IAM user passwords |
| require_lowercase_characters | Whether lowercase characters are required |
| require_numbers | Whether numbers are required |
| require_uppercase_characters | Whether uppercase characters are required |
| require_symbols | Whether symbols are required |
| allow_users_to_change_password | Whether users can change their own password |
| hard_expiry | Whether hard expiry is enabled |
| max_password_age | Password validity period in days |
| password_reuse_prevention | Number of previous passwords prevented from reuse |

### AWS Support Role Outputs

| Name | Description |
|------|-------------|
| aws_support_role_enabled | Whether AWS Support role is enabled |
| aws_support_role_arn | The ARN of the AWS Support role |
| aws_support_role_name | The name of the AWS Support role |
| aws_support_role_unique_id | The unique ID of the AWS Support role |
| aws_support_role_trusted_entities | List of trusted entities |
| aws_support_role_requires_mfa | Whether MFA is required |
| aws_support_role_uses_default_trusted_entities | Whether using default trusted entities |

### S3 Public Access Block Outputs

| Name | Description |
|------|-------------|
| s3_account_public_access_block_enabled | Whether S3 public access block is enabled |
| s3_account_public_access_block_id | Account ID for public access block configuration |
| s3_public_access_settings | Current S3 public access block settings |

### EBS Encryption Outputs

| Name | Description |
|------|-------------|
| ebs_encryption_by_default_enabled | Whether EBS encryption by default is enabled |
| ebs_encryption_by_default_id | Region where EBS encryption is configured |
| ebs_default_kms_key_arn | ARN of KMS key used for EBS encryption |
| ebs_kms_key_created | Whether a new KMS key was created |
| ebs_kms_key_id | ID of the created KMS key |
| ebs_kms_key_alias | Alias of the created KMS key |

### Compliance Summary

| Name | Description |
|------|-------------|
| security_controls_summary | Summary of deployed security controls and compliance status |
| module_configuration | Module configuration details for debugging and validation |

## Security Considerations

### IAM Password Policy

- **Account-Level Policy**: AWS IAM password policies apply to the entire AWS account
- **Single Policy**: Only one password policy can exist per AWS account  
- **IAM Users Only**: Password policy only affects IAM users, not root account or federated users
- **Import Existing**: If a policy already exists, use `terraform import` to manage it

### AWS Support Role

- **Principle of Least Privilege**: Role only has AWS Support access permissions
- **Trusted Entities Control**: Configure only necessary AWS accounts, users, or roles
- **MFA Enforcement**: Enable MFA requirement for enhanced security
- **Session Management**: Set appropriate maximum session duration
- **Regular Auditing**: Monitor role usage through AWS CloudTrail

### S3 Public Access Block

- **Account-Level Protection**: Settings apply to all buckets in the account
- **Cannot Override**: Individual bucket settings cannot override account-level blocks
- **Immediate Effect**: Changes take effect immediately for all buckets
- **No Data Loss**: Existing bucket content is not affected, only access permissions

### EBS Encryption

- **Region-Specific**: EBS encryption by default is configured per AWS region
- **New Volumes Only**: Only affects new EBS volumes; existing volumes remain unchanged
- **Performance**: Encrypted EBS volumes have minimal performance impact
- **Key Management**: If using custom KMS keys, ensure proper key policies for EC2 service access

## Compliance Impact

After deploying this module with default settings:

- **IAM.7**: Password policy controls show as **COMPLIANT**
- **IAM.11-17**: Individual password complexity controls show as **COMPLIANT**
- **IAM.18**: Support role control shows as **COMPLIANT**
- **S3.1**: S3 public access control shows as **COMPLIANT**
- **EC2.7**: EBS encryption control shows as **COMPLIANT**

## Examples

### Multi-Region Deployment

```hcl
# Deploy in multiple regions for comprehensive coverage
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west_2"  
  region = "us-west-2"
}

module "security_baseline_us_east_1" {
  source = "./modules/security-baseline"
  
  providers = {
    aws = aws.us_east_1
  }

  enable_iam_password_policy            = true
  enable_aws_support_role               = true  # Support role is account-wide
  enable_s3_account_public_access_block = true  # S3 settings are account-wide
  enable_ebs_encryption_by_default      = true
  create_ebs_kms_key                   = true
  ebs_kms_key_alias                    = "alias/ebs-encryption-us-east-1"

  aws_support_role_trusted_entities = [
    "arn:aws:iam::123456789012:role/SecurityTeam"
  ]

  tags = {
    Environment = "production"
    Region      = "us-east-1"
  }
}

module "security_baseline_us_west_2" {
  source = "./modules/security-baseline"
  
  providers = {
    aws = aws.us_west_2
  }

  enable_iam_password_policy            = false # Password policy is account-wide
  enable_aws_support_role               = false # Support role is account-wide
  enable_s3_account_public_access_block = false # S3 settings are account-wide  
  enable_ebs_encryption_by_default      = true
  create_ebs_kms_key                   = true
  ebs_kms_key_alias                    = "alias/ebs-encryption-us-west-2"

  tags = {
    Environment = "production"
    Region      = "us-west-2"
  }
}
```

### Testing Configuration

```hcl
# Create test user to verify password policy
resource "aws_iam_user" "test_user" {
  name = "test-password-policy-user"
  path = "/test/"
}

resource "aws_iam_user_login_profile" "test_user" {
  user    = aws_iam_user.test_user.name
  password = "TestPassword123!@#$%"
  password_reset_required = true
}

# Test Support role assumption
output "support_role_test_command" {
  value = "aws sts assume-role --role-arn ${module.security_baseline.aws_support_role_arn} --role-session-name support-access-test"
}
```

## Troubleshooting

### Common Issues

1. **Password Policy Conflicts**: 
   - AWS allows only one password policy per account
   - Import existing policy or remove conflicting one

2. **Support Role Access Issues**:
   - Verify trusted entities are correctly formatted as AWS ARNs
   - Check MFA requirements if enabled

3. **S3 Access Denied Errors**:
   - After enabling public access block, ensure applications use proper IAM roles
   - Review bucket policies for compatibility

4. **KMS Permission Errors**:
   - Verify EC2 service has proper permissions in key policy
   - Check cross-region key usage policies

### Verification Commands

```bash
# Check password policy
aws iam get-account-password-policy

# Check Support role
aws iam get-role --role-name AWSSupport-IncidentManagement

# Check S3 public access block
aws s3control get-public-access-block --account-id $(aws sts get-caller-identity --query Account --output text)

# Check EBS encryption
aws ec2 get-ebs-encryption-by-default

# Verify SecurityHub compliance
aws securityhub get-findings --filters '{"ComplianceStatus":[{"Value":"FAILED","Comparison":"EQUALS"}],"RecordState":[{"Value":"ACTIVE","Comparison":"EQUALS"}]}'
```

## Best Practices

1. **Gradual Implementation**: Test in non-production environments first
2. **User Communication**: Notify users about password policy changes
3. **Documentation**: Maintain records of who should have Support role access
4. **Regular Reviews**: Periodically audit trusted entities and access patterns
5. **Monitoring**: Implement CloudTrail logging for security events
6. **Backup Procedures**: Ensure administrative access for password resets

## Contributing

When contributing to this module:

1. Ensure all variables have proper descriptions and validation
2. Add appropriate tags to all resources
3. Update documentation for any new features or breaking changes
4. Follow the existing code style and organization
5. Test all security controls in isolation and combination

## License

This module is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Support

For issues related to:
- **AWS Security Hub**: Consult AWS documentation and support
- **AWS Support Service**: Contact AWS Support for service-specific issues
- **Terraform**: Check Terraform AWS provider documentation
- **Module Issues**: Create an issue in the repository

---

**Note**: This module implements fundamental security controls often required for compliance frameworks like SOC 2, PCI DSS, CIS AWS Foundations Benchmark, and AWS Config rules. Always test thoroughly in non-production environments first.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_default_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_default_kms_key) | resource |
| [aws_ebs_encryption_by_default.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_role.aws_support_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.aws_support_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.ebs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.ebs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_account_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_users_to_change_password"></a> [allow\_users\_to\_change\_password](#input\_allow\_users\_to\_change\_password) | Whether to allow users to change their own password | `bool` | `true` | no |
| <a name="input_aws_support_role_max_session_duration"></a> [aws\_support\_role\_max\_session\_duration](#input\_aws\_support\_role\_max\_session\_duration) | Maximum session duration (in seconds) for the AWS Support role | `number` | `3600` | no |
| <a name="input_aws_support_role_name"></a> [aws\_support\_role\_name](#input\_aws\_support\_role\_name) | The name of the AWS Support role | `string` | `"AWSSupport-IncidentManagement"` | no |
| <a name="input_aws_support_role_path"></a> [aws\_support\_role\_path](#input\_aws\_support\_role\_path) | The path for the AWS Support role | `string` | `"/"` | no |
| <a name="input_aws_support_role_require_mfa"></a> [aws\_support\_role\_require\_mfa](#input\_aws\_support\_role\_require\_mfa) | Whether to require MFA for assuming the AWS Support role | `bool` | `true` | no |
| <a name="input_aws_support_role_tags"></a> [aws\_support\_role\_tags](#input\_aws\_support\_role\_tags) | A map of tags to apply to the AWS Support role | `map(string)` | <pre>{<br/>  "ManagedBy": "terraform",<br/>  "Name": "AWS Support Role",<br/>  "Purpose": "AWS Support incident management",<br/>  "SecurityHub": "IAM.18"<br/>}</pre> | no |
| <a name="input_aws_support_role_trusted_entities"></a> [aws\_support\_role\_trusted\_entities](#input\_aws\_support\_role\_trusted\_entities) | List of AWS account ARNs or IAM user/role ARNs that can assume the AWS Support role. If empty, defaults to current account root for security and IAM.18 compliance | `list(string)` | `[]` | no |
| <a name="input_create_ebs_kms_key"></a> [create\_ebs\_kms\_key](#input\_create\_ebs\_kms\_key) | Whether to create a dedicated KMS key for EBS encryption | `bool` | `false` | no |
| <a name="input_ebs_encryption_enabled"></a> [ebs\_encryption\_enabled](#input\_ebs\_encryption\_enabled) | Whether or not default EBS encryption is enabled | `bool` | `true` | no |
| <a name="input_ebs_kms_key_alias"></a> [ebs\_kms\_key\_alias](#input\_ebs\_kms\_key\_alias) | The alias name for the EBS KMS key (must start with 'alias/') | `string` | `"alias/security-baseline-ebs-encryption"` | no |
| <a name="input_ebs_kms_key_arn"></a> [ebs\_kms\_key\_arn](#input\_ebs\_kms\_key\_arn) | The ARN of the AWS KMS key to use for EBS encryption (optional - uses AWS managed key if not specified) | `string` | `null` | no |
| <a name="input_ebs_kms_key_deletion_window"></a> [ebs\_kms\_key\_deletion\_window](#input\_ebs\_kms\_key\_deletion\_window) | Duration in days after which the key is deleted after destruction of the resource | `number` | `7` | no |
| <a name="input_ebs_kms_key_rotation"></a> [ebs\_kms\_key\_rotation](#input\_ebs\_kms\_key\_rotation) | Whether to enable automatic rotation of the KMS key | `bool` | `true` | no |
| <a name="input_enable_aws_support_role"></a> [enable\_aws\_support\_role](#input\_enable\_aws\_support\_role) | Whether to create an AWS Support role for incident management (SecurityHub IAM.18) | `bool` | `true` | no |
| <a name="input_enable_ebs_encryption_by_default"></a> [enable\_ebs\_encryption\_by\_default](#input\_enable\_ebs\_encryption\_by\_default) | Whether to enable EBS encryption by default | `bool` | `true` | no |
| <a name="input_enable_iam_password_policy"></a> [enable\_iam\_password\_policy](#input\_enable\_iam\_password\_policy) | Whether to create the IAM password policy | `bool` | `true` | no |
| <a name="input_enable_s3_account_public_access_block"></a> [enable\_s3\_account\_public\_access\_block](#input\_enable\_s3\_account\_public\_access\_block) | Whether to enable S3 account public access block configuration | `bool` | `true` | no |
| <a name="input_hard_expiry"></a> [hard\_expiry](#input\_hard\_expiry) | Whether users are prevented from setting a new password after their password has expired (i.e., hard expiry) | `bool` | `false` | no |
| <a name="input_max_password_age"></a> [max\_password\_age](#input\_max\_password\_age) | The number of days that an IAM user password is valid | `number` | `90` | no |
| <a name="input_minimum_password_length"></a> [minimum\_password\_length](#input\_minimum\_password\_length) | Minimum length to require for IAM user passwords | `number` | `14` | no |
| <a name="input_password_reuse_prevention"></a> [password\_reuse\_prevention](#input\_password\_reuse\_prevention) | The number of previous passwords that users are prevented from reusing | `number` | `24` | no |
| <a name="input_require_lowercase_characters"></a> [require\_lowercase\_characters](#input\_require\_lowercase\_characters) | Whether to require lowercase characters for IAM user passwords | `bool` | `true` | no |
| <a name="input_require_numbers"></a> [require\_numbers](#input\_require\_numbers) | Whether to require numbers for IAM user passwords | `bool` | `true` | no |
| <a name="input_require_symbols"></a> [require\_symbols](#input\_require\_symbols) | Whether to require symbols for IAM user passwords | `bool` | `true` | no |
| <a name="input_require_uppercase_characters"></a> [require\_uppercase\_characters](#input\_require\_uppercase\_characters) | Whether to require uppercase characters for IAM user passwords | `bool` | `true` | no |
| <a name="input_s3_block_public_acls"></a> [s3\_block\_public\_acls](#input\_s3\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for buckets in this account | `bool` | `true` | no |
| <a name="input_s3_block_public_policy"></a> [s3\_block\_public\_policy](#input\_s3\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for buckets in this account | `bool` | `true` | no |
| <a name="input_s3_ignore_public_acls"></a> [s3\_ignore\_public\_acls](#input\_s3\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for buckets in this account | `bool` | `true` | no |
| <a name="input_s3_restrict_public_buckets"></a> [s3\_restrict\_public\_buckets](#input\_s3\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for buckets in this account | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_allow_users_to_change_password"></a> [allow\_users\_to\_change\_password](#output\_allow\_users\_to\_change\_password) | Whether users are allowed to change their own password |
| <a name="output_aws_support_role_arn"></a> [aws\_support\_role\_arn](#output\_aws\_support\_role\_arn) | The ARN of the AWS Support role (if created) |
| <a name="output_aws_support_role_enabled"></a> [aws\_support\_role\_enabled](#output\_aws\_support\_role\_enabled) | Whether AWS Support role is enabled |
| <a name="output_aws_support_role_name"></a> [aws\_support\_role\_name](#output\_aws\_support\_role\_name) | The name of the AWS Support role (if created) |
| <a name="output_aws_support_role_requires_mfa"></a> [aws\_support\_role\_requires\_mfa](#output\_aws\_support\_role\_requires\_mfa) | Whether the AWS Support role requires MFA for assumption |
| <a name="output_aws_support_role_trusted_entities"></a> [aws\_support\_role\_trusted\_entities](#output\_aws\_support\_role\_trusted\_entities) | List of trusted entities that can assume the AWS Support role |
| <a name="output_aws_support_role_unique_id"></a> [aws\_support\_role\_unique\_id](#output\_aws\_support\_role\_unique\_id) | The unique ID of the AWS Support role (if created) |
| <a name="output_aws_support_role_uses_default_trusted_entities"></a> [aws\_support\_role\_uses\_default\_trusted\_entities](#output\_aws\_support\_role\_uses\_default\_trusted\_entities) | Whether the AWS Support role is using default trusted entities (current account root) |
| <a name="output_ebs_default_kms_key_arn"></a> [ebs\_default\_kms\_key\_arn](#output\_ebs\_default\_kms\_key\_arn) | The ARN of the KMS key used for EBS default encryption |
| <a name="output_ebs_encryption_by_default_enabled"></a> [ebs\_encryption\_by\_default\_enabled](#output\_ebs\_encryption\_by\_default\_enabled) | Whether EBS encryption by default is enabled |
| <a name="output_ebs_encryption_by_default_id"></a> [ebs\_encryption\_by\_default\_id](#output\_ebs\_encryption\_by\_default\_id) | The region where EBS encryption by default is configured |
| <a name="output_ebs_kms_key_alias"></a> [ebs\_kms\_key\_alias](#output\_ebs\_kms\_key\_alias) | The alias of the created KMS key for EBS encryption (if created) |
| <a name="output_ebs_kms_key_created"></a> [ebs\_kms\_key\_created](#output\_ebs\_kms\_key\_created) | Whether a new KMS key was created for EBS encryption |
| <a name="output_ebs_kms_key_id"></a> [ebs\_kms\_key\_id](#output\_ebs\_kms\_key\_id) | The ID of the created KMS key for EBS encryption (if created) |
| <a name="output_hard_expiry"></a> [hard\_expiry](#output\_hard\_expiry) | Whether users are prevented from setting a new password after their password has expired |
| <a name="output_iam_password_policy_enabled"></a> [iam\_password\_policy\_enabled](#output\_iam\_password\_policy\_enabled) | Whether IAM password policy is enabled |
| <a name="output_max_password_age"></a> [max\_password\_age](#output\_max\_password\_age) | The number of days that an IAM user password is valid |
| <a name="output_minimum_password_length"></a> [minimum\_password\_length](#output\_minimum\_password\_length) | Minimum length to require for IAM user passwords |
| <a name="output_module_configuration"></a> [module\_configuration](#output\_module\_configuration) | Module configuration details for debugging and validation |
| <a name="output_password_policy_arn"></a> [password\_policy\_arn](#output\_password\_policy\_arn) | The ARN of the IAM password policy |
| <a name="output_password_reuse_prevention"></a> [password\_reuse\_prevention](#output\_password\_reuse\_prevention) | The number of previous passwords that users are prevented from reusing |
| <a name="output_require_lowercase_characters"></a> [require\_lowercase\_characters](#output\_require\_lowercase\_characters) | Whether lowercase characters are required for IAM user passwords |
| <a name="output_require_numbers"></a> [require\_numbers](#output\_require\_numbers) | Whether numbers are required for IAM user passwords |
| <a name="output_require_symbols"></a> [require\_symbols](#output\_require\_symbols) | Whether symbols are required for IAM user passwords |
| <a name="output_require_uppercase_characters"></a> [require\_uppercase\_characters](#output\_require\_uppercase\_characters) | Whether uppercase characters are required for IAM user passwords |
| <a name="output_s3_account_public_access_block_enabled"></a> [s3\_account\_public\_access\_block\_enabled](#output\_s3\_account\_public\_access\_block\_enabled) | Whether S3 account public access block is enabled |
| <a name="output_s3_account_public_access_block_id"></a> [s3\_account\_public\_access\_block\_id](#output\_s3\_account\_public\_access\_block\_id) | The account ID for which the S3 account public access block configuration is applied |
| <a name="output_s3_public_access_settings"></a> [s3\_public\_access\_settings](#output\_s3\_public\_access\_settings) | Current S3 public access block settings |
| <a name="output_security_controls_summary"></a> [security\_controls\_summary](#output\_security\_controls\_summary) | Summary of deployed security controls and their compliance status |
<!-- END_TF_DOCS -->