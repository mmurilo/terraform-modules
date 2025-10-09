# AWS Security Controls Terraform Module

This Terraform module implements AWS Security Hub controls for fundamental security compliance. It addresses critical security controls by configuring S3 public access restrictions, EBS default encryption, and AWS Support role creation at the AWS account level.

## Security Controls Addressed

### [S3.1] S3 general purpose buckets should have block public access settings enabled

This control ensures that S3 buckets cannot be made publicly accessible through ACLs or bucket policies. The module configures account-level settings that apply to all buckets in the AWS account:

- **Block Public ACLs**: Prevents any public ACLs from being applied to buckets or objects
- **Block Public Policy**: Rejects bucket policies that allow public access
- **Ignore Public ACLs**: Ignores any existing public ACLs on buckets and objects
- **Restrict Public Buckets**: Restricts access to buckets with public policies to only the bucket owner and AWS services

**AWS Documentation**: [S3.1 Security Control](https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html#s3-1)

### [EC2.7] EBS default encryption should be enabled

This control ensures that all new EBS volumes are encrypted by default using either AWS managed keys or customer managed KMS keys. This provides data protection at rest for all EBS volumes in the account.

**AWS Documentation**: [EC2.7 Security Control](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-7) | [EBS Encryption by Default](https://docs.aws.amazon.com/ebs/latest/userguide/encryption-by-default.html)

### [IAM.18] Ensure a support role has been created to manage incidents with AWS Support

This control ensures that an IAM role exists with the `AWSSupportAccess` managed policy attached, allowing authorized users to manage incidents with AWS Support. The module creates a properly configured role with the following features:

- **AWSSupportAccess Policy**: Automatically attaches the AWS managed policy for Support access
- **Trusted Entities**: Configurable list of AWS accounts, users, or roles that can assume the role
- **MFA Requirement**: Optional multi-factor authentication requirement for role assumption
- **Session Duration**: Configurable maximum session duration (1-12 hours)
- **Secure Defaults**: Follows AWS security best practices with principle of least privilege

**AWS Documentation**: [IAM.18 Security Control](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-18) | [AWS Support](https://docs.aws.amazon.com/support/)

## Features

- ✅ Account-level S3 public access blocking (SecurityHub S3.1)
- ✅ EBS default encryption enablement (SecurityHub EC2.7)
- ✅ AWS Support role creation with proper policies (SecurityHub IAM.18)
- ✅ Optional custom KMS key creation for EBS encryption
- ✅ Comprehensive compliance status outputs
- ✅ Configurable settings with secure defaults
- ✅ Input validation for all variables
- ✅ Support for existing KMS keys or AWS managed keys
- ✅ MFA enforcement options for Support role access

## Usage

### Basic Usage (Recommended)

```hcl
module "security_controls" {
  source = "./terraform-aws-security-controls"

  # Enable all controls with secure defaults
  enable_s3_account_public_access_block = true
  enable_ebs_encryption_by_default     = true
  enable_aws_support_role               = true

  # Configure AWS Support role trusted entities
  aws_support_role_trusted_entities = [
    "arn:aws:iam::123456789012:root",  # Trusted AWS account
    "arn:aws:iam::123456789012:user/admin-user",  # Specific IAM user
    "arn:aws:iam::123456789012:role/SecurityAdministrator"  # Specific IAM role
  ]

  tags = {
    Environment = "production"
    Owner       = "security-team"
    Purpose     = "SecurityHub compliance"
  }
}
```

### Advanced Usage with Custom Configurations

```hcl
module "security_controls" {
  source = "./terraform-aws-security-controls"

  # S3 Settings (all defaults to true for maximum security)
  enable_s3_account_public_access_block = true
  s3_block_public_acls                 = true
  s3_block_public_policy               = true
  s3_ignore_public_acls                = true
  s3_restrict_public_buckets           = true

  # EBS Settings with custom KMS key
  enable_ebs_encryption_by_default = true
  ebs_encryption_enabled           = true
  create_ebs_kms_key              = true
  ebs_kms_key_alias               = "alias/my-ebs-encryption-key"
  ebs_kms_key_rotation            = true

  # AWS Support Role Settings (IAM.18)
  enable_aws_support_role                = true
  aws_support_role_name                  = "CustomSupportRole"
  aws_support_role_path                  = "/security/"
  aws_support_role_max_session_duration  = 7200  # 2 hours
  aws_support_role_require_mfa          = true
  aws_support_role_trusted_entities     = [
    "arn:aws:iam::123456789012:role/SecurityTeam",
    "arn:aws:iam::987654321098:user/support-admin"
  ]

  tags = {
    Environment = "production"
    Owner       = "security-team"
    Purpose     = "SecurityHub compliance"
    Project     = "security-hardening"
  }
}
```

### Using Existing KMS Key

```hcl
# Reference existing KMS key
data "aws_kms_key" "existing" {
  key_id = "alias/my-existing-key"
}

module "security_controls" {
  source = "./terraform-aws-security-controls"

  enable_s3_account_public_access_block = true
  enable_ebs_encryption_by_default     = true
  enable_aws_support_role               = true
  
  # Use existing KMS key for EBS encryption
  ebs_kms_key_arn = data.aws_kms_key.existing.arn

  # Simple Support role configuration
  aws_support_role_trusted_entities = [
    "arn:aws:iam::123456789012:root"
  ]

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| enable_s3_account_public_access_block | Whether to enable S3 account public access block configuration | `bool` | `true` | no |
| s3_block_public_acls | Whether Amazon S3 should block public ACLs for buckets in this account | `bool` | `true` | no |
| s3_block_public_policy | Whether Amazon S3 should block public bucket policies for buckets in this account | `bool` | `true` | no |
| s3_ignore_public_acls | Whether Amazon S3 should ignore public ACLs for buckets in this account | `bool` | `true` | no |
| s3_restrict_public_buckets | Whether Amazon S3 should restrict public bucket policies for buckets in this account | `bool` | `true` | no |
| enable_ebs_encryption_by_default | Whether to enable EBS encryption by default | `bool` | `true` | no |
| ebs_encryption_enabled | Whether or not default EBS encryption is enabled | `bool` | `true` | no |
| ebs_kms_key_arn | The ARN of the AWS KMS key to use for EBS encryption (optional - uses AWS managed key if not specified) | `string` | `null` | no |
| create_ebs_kms_key | Whether to create a dedicated KMS key for EBS encryption | `bool` | `false` | no |
| ebs_kms_key_deletion_window | Duration in days after which the key is deleted after destruction of the resource | `number` | `7` | no |
| ebs_kms_key_rotation | Whether to enable automatic rotation of the KMS key | `bool` | `true` | no |
| ebs_kms_key_alias | The alias name for the EBS KMS key (must start with 'alias/') | `string` | `"alias/security-controls-ebs-encryption"` | no |
| enable_aws_support_role | Whether to create an AWS Support role for incident management (SecurityHub IAM.18) | `bool` | `true` | no |
| aws_support_role_name | The name of the AWS Support role | `string` | `"AWSSupport-IncidentManagement"` | no |
| aws_support_role_path | The path for the AWS Support role | `string` | `"/"` | no |
| aws_support_role_max_session_duration | Maximum session duration (in seconds) for the AWS Support role | `number` | `3600` | no |
| aws_support_role_trusted_entities | List of AWS account ARNs or IAM user/role ARNs that can assume the AWS Support role | `list(string)` | `[]` | no |
| aws_support_role_require_mfa | Whether to require MFA for assuming the AWS Support role | `bool` | `true` | no |
| tags | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3_account_public_access_block_enabled | Whether S3 account public access block is enabled |
| s3_account_public_access_block_id | The account ID for which the S3 account public access block configuration is applied |
| s3_public_access_settings | Current S3 public access block settings |
| ebs_encryption_by_default_enabled | Whether EBS encryption by default is enabled |
| ebs_encryption_by_default_id | The region where EBS encryption by default is configured |
| ebs_default_kms_key_arn | The ARN of the KMS key used for EBS default encryption |
| ebs_kms_key_created | Whether a new KMS key was created for EBS encryption |
| ebs_kms_key_id | The ID of the created KMS key for EBS encryption (if created) |
| ebs_kms_key_alias | The alias of the created KMS key for EBS encryption (if created) |
| aws_support_role_enabled | Whether AWS Support role is enabled |
| aws_support_role_arn | The ARN of the AWS Support role (if created) |
| aws_support_role_name | The name of the AWS Support role (if created) |
| aws_support_role_unique_id | The unique ID of the AWS Support role (if created) |
| aws_support_role_trusted_entities | List of trusted entities that can assume the AWS Support role |
| aws_support_role_requires_mfa | Whether the AWS Support role requires MFA for assumption |
| security_controls_summary | Summary of deployed security controls and their compliance status |
| module_configuration | Module configuration details for debugging and validation |

## Security Considerations

### S3 Public Access Block

- **Account-Level Protection**: This module configures account-level settings that cannot be overridden by individual bucket configurations
- **Immediate Effect**: Changes take effect immediately for all buckets in the account
- **No Data Loss**: Existing bucket content is not affected, only access permissions

### EBS Encryption

- **Region-Specific**: EBS encryption by default is configured per AWS region
- **New Volumes Only**: Only affects new EBS volumes; existing volumes remain unchanged
- **Performance**: Encrypted EBS volumes have minimal performance impact
- **Key Management**: If using custom KMS keys, ensure proper key policies for EC2 service access

### AWS Support Role (IAM.18)

- **Principle of Least Privilege**: Role only has AWS Support access permissions
- **Trusted Entities**: Configure only necessary AWS accounts, users, or roles as trusted entities
- **MFA Enforcement**: Enable MFA requirement for enhanced security
- **Session Duration**: Set appropriate maximum session duration based on operational needs
- **Monitoring**: Monitor role usage through AWS CloudTrail for security auditing

## Implementation Details

### Resources Created

1. **aws_s3_account_public_access_block**: Account-level S3 public access restriction
2. **aws_ebs_encryption_by_default**: Regional default EBS encryption setting
3. **aws_ebs_default_kms_key**: (Optional) Custom KMS key for EBS encryption
4. **aws_kms_key**: (Optional) Dedicated KMS key with proper policies
5. **aws_kms_alias**: (Optional) Alias for the created KMS key
6. **aws_iam_role**: AWS Support role for incident management
7. **aws_iam_role_policy_attachment**: Attaches AWSSupportAccess policy to the role

### Compliance Impact

After deploying this module with default settings:
- SecurityHub control **S3.1** will show as **COMPLIANT**
- SecurityHub control **EC2.7** will show as **COMPLIANT**
- SecurityHub control **IAM.18** will show as **COMPLIANT**
- All new S3 buckets will be protected from public access
- All new EBS volumes will be encrypted by default
- AWS Support access will be available through the created IAM role

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

module "security_controls_us_east_1" {
  source = "./terraform-aws-security-controls"
  
  providers = {
    aws = aws.us_east_1
  }

  enable_s3_account_public_access_block = true
  enable_ebs_encryption_by_default     = true
  enable_aws_support_role               = true
  create_ebs_kms_key                   = true
  ebs_kms_key_alias                    = "alias/ebs-encryption-us-east-1"

  # Support role only needs to be created once per account
  aws_support_role_trusted_entities = [
    "arn:aws:iam::123456789012:role/SecurityTeam"
  ]

  tags = {
    Environment = "production"
    Region      = "us-east-1"
  }
}

module "security_controls_us_west_2" {
  source = "./terraform-aws-security-controls"
  
  providers = {
    aws = aws.us_west_2
  }

  enable_s3_account_public_access_block = false  # S3 settings are account-wide
  enable_ebs_encryption_by_default     = true
  enable_aws_support_role               = false  # Role is account-wide, create only once
  create_ebs_kms_key                   = true
  ebs_kms_key_alias                    = "alias/ebs-encryption-us-west-2"

  tags = {
    Environment = "production"
    Region      = "us-west-2"
  }
}
```

## AWS Support Role Best Practices

1. **Minimal Trusted Entities**: Only configure necessary AWS accounts, users, or roles as trusted entities
2. **Enable MFA**: Always require multi-factor authentication for role assumption
3. **Session Duration**: Set the shortest practical session duration for your use case
4. **Regular Review**: Periodically review and audit the trusted entities list
5. **CloudTrail Monitoring**: Monitor role usage through AWS CloudTrail logs
6. **Documentation**: Document which users/roles should have access and for what purposes

## Troubleshooting

### Common Issues

1. **S3 Access Denied Errors**: After enabling S3 public access block, ensure applications use proper IAM roles instead of public access
2. **KMS Permission Errors**: If using custom KMS keys, verify that EC2 service has proper permissions in the key policy
3. **Support Role Access**: Verify trusted entities are correctly formatted as AWS ARNs
4. **MFA Requirements**: Ensure users have MFA configured when MFA is required for Support role assumption

### Verification

Check compliance status using the module outputs:

```hcl
output "compliance_status" {
  value = module.security_controls.security_controls_summary
}

output "support_role_info" {
  value = {
    arn              = module.security_controls.aws_support_role_arn
    name             = module.security_controls.aws_support_role_name
    trusted_entities = module.security_controls.aws_support_role_trusted_entities
    requires_mfa     = module.security_controls.aws_support_role_requires_mfa
  }
}
```

## Contributing

When contributing to this module:
1. Ensure all variables have proper descriptions and validation
2. Add appropriate tags to all resources
3. Update the README with any new features or breaking changes
4. Follow the existing code style and organization
5. Test IAM role assumption and AWS Support access functionality

## License

This module is provided under the MIT License. See LICENSE file for details.

## Support

For issues related to:
- **AWS Security Hub**: Consult AWS documentation and support
- **AWS Support Service**: Contact AWS Support for service-specific issues
- **Terraform**: Check Terraform AWS provider documentation
- **Module Issues**: Create an issue in the repository

---

**Note**: This module implements fundamental security controls that are often required for compliance frameworks like SOC 2, PCI DSS, and AWS Config rules. Always test in non-production environments first.
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
| [aws_ebs_default_kms_key.created_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_default_kms_key) | resource |
| [aws_ebs_default_kms_key.security_control](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_default_kms_key) | resource |
| [aws_ebs_encryption_by_default.security_control](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_kms_alias.ebs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.ebs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_account_public_access_block.security_control](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_ebs_kms_key"></a> [create\_ebs\_kms\_key](#input\_create\_ebs\_kms\_key) | Whether to create a dedicated KMS key for EBS encryption | `bool` | `false` | no |
| <a name="input_ebs_encryption_enabled"></a> [ebs\_encryption\_enabled](#input\_ebs\_encryption\_enabled) | Whether or not default EBS encryption is enabled | `bool` | `true` | no |
| <a name="input_ebs_kms_key_alias"></a> [ebs\_kms\_key\_alias](#input\_ebs\_kms\_key\_alias) | The alias name for the EBS KMS key (must start with 'alias/') | `string` | `"alias/security-controls-ebs-encryption"` | no |
| <a name="input_ebs_kms_key_arn"></a> [ebs\_kms\_key\_arn](#input\_ebs\_kms\_key\_arn) | The ARN of the AWS KMS key to use for EBS encryption (optional - uses AWS managed key if not specified) | `string` | `null` | no |
| <a name="input_ebs_kms_key_deletion_window"></a> [ebs\_kms\_key\_deletion\_window](#input\_ebs\_kms\_key\_deletion\_window) | Duration in days after which the key is deleted after destruction of the resource | `number` | `7` | no |
| <a name="input_ebs_kms_key_rotation"></a> [ebs\_kms\_key\_rotation](#input\_ebs\_kms\_key\_rotation) | Whether to enable automatic rotation of the KMS key | `bool` | `true` | no |
| <a name="input_enable_ebs_encryption_by_default"></a> [enable\_ebs\_encryption\_by\_default](#input\_enable\_ebs\_encryption\_by\_default) | Whether to enable EBS encryption by default | `bool` | `true` | no |
| <a name="input_enable_s3_account_public_access_block"></a> [enable\_s3\_account\_public\_access\_block](#input\_enable\_s3\_account\_public\_access\_block) | Whether to enable S3 account public access block configuration | `bool` | `true` | no |
| <a name="input_s3_block_public_acls"></a> [s3\_block\_public\_acls](#input\_s3\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for buckets in this account | `bool` | `true` | no |
| <a name="input_s3_block_public_policy"></a> [s3\_block\_public\_policy](#input\_s3\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for buckets in this account | `bool` | `true` | no |
| <a name="input_s3_ignore_public_acls"></a> [s3\_ignore\_public\_acls](#input\_s3\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for buckets in this account | `bool` | `true` | no |
| <a name="input_s3_restrict_public_buckets"></a> [s3\_restrict\_public\_buckets](#input\_s3\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for buckets in this account | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ebs_default_kms_key_arn"></a> [ebs\_default\_kms\_key\_arn](#output\_ebs\_default\_kms\_key\_arn) | The ARN of the KMS key used for EBS default encryption |
| <a name="output_ebs_encryption_by_default_enabled"></a> [ebs\_encryption\_by\_default\_enabled](#output\_ebs\_encryption\_by\_default\_enabled) | Whether EBS encryption by default is enabled |
| <a name="output_ebs_encryption_by_default_id"></a> [ebs\_encryption\_by\_default\_id](#output\_ebs\_encryption\_by\_default\_id) | The region where EBS encryption by default is configured |
| <a name="output_ebs_kms_key_alias"></a> [ebs\_kms\_key\_alias](#output\_ebs\_kms\_key\_alias) | The alias of the created KMS key for EBS encryption (if created) |
| <a name="output_ebs_kms_key_created"></a> [ebs\_kms\_key\_created](#output\_ebs\_kms\_key\_created) | Whether a new KMS key was created for EBS encryption |
| <a name="output_ebs_kms_key_id"></a> [ebs\_kms\_key\_id](#output\_ebs\_kms\_key\_id) | The ID of the created KMS key for EBS encryption (if created) |
| <a name="output_module_configuration"></a> [module\_configuration](#output\_module\_configuration) | Module configuration details for debugging and validation |
| <a name="output_s3_account_public_access_block_enabled"></a> [s3\_account\_public\_access\_block\_enabled](#output\_s3\_account\_public\_access\_block\_enabled) | Whether S3 account public access block is enabled |
| <a name="output_s3_account_public_access_block_id"></a> [s3\_account\_public\_access\_block\_id](#output\_s3\_account\_public\_access\_block\_id) | The account ID for which the S3 account public access block configuration is applied |
| <a name="output_s3_public_access_settings"></a> [s3\_public\_access\_settings](#output\_s3\_public\_access\_settings) | Current S3 public access block settings |
| <a name="output_security_controls_summary"></a> [security\_controls\_summary](#output\_security\_controls\_summary) | Summary of deployed security controls and their compliance status |
<!-- END_TF_DOCS -->