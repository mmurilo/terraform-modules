# AWS IAM Password Policy & Support Role Terraform Module

This Terraform module creates an AWS IAM password policy with security best practices and an AWS Support role for incident management, addressing multiple SecurityHub IAM controls including minimum password length of 14 characters, password reuse prevention, comprehensive character requirements, and AWS Support access management.

## Features

### IAM Password Policy (SecurityHub Controls IAM.7, IAM.11-17)
- ✅ **Security Best Practices**: Implements AWS security best practices for password policies
- ✅ **Minimum Password Length**: Enforces minimum password length of 14 characters (configurable)
- ✅ **Password Reuse Prevention**: Prevents reuse of previous passwords (default: 24 passwords)
- ✅ **Character Complexity**: Requires uppercase, lowercase, numbers, and symbols
- ✅ **Password Expiration**: Configurable password expiration (default: 90 days)
- ✅ **User Control**: Allows users to change their own passwords
- ✅ **Validation**: Input validation for all parameters
- ✅ **Flexible**: All settings are configurable with sensible defaults

### AWS Support Role (SecurityHub Control IAM.18)
- ✅ **AWS Support Access**: Creates IAM role with AWSSupportAccess managed policy
- ✅ **Trusted Entities**: Configurable list of AWS accounts, users, or roles that can assume the role
- ✅ **Default Behavior**: If no trusted entities are specified, defaults to current account root for security
- ✅ **MFA Requirement**: Optional multi-factor authentication requirement for role assumption
- ✅ **Session Duration**: Configurable maximum session duration (1-12 hours)
- ✅ **Secure Defaults**: Follows AWS security best practices with principle of least privilege
- ✅ **Tagging**: Comprehensive tagging for compliance and management

## Security Compliance

This module helps achieve compliance with:

### IAM Password Policy Controls
- **CIS AWS Foundations Benchmark 1.9**: Ensure IAM password policy requires minimum length of 14 or greater
- **CIS AWS Foundations Benchmark 1.10**: Ensure IAM password policy prevents password reuse
- **SecurityHub IAM.7**: Password policies for IAM users should have strong configurations
- **SecurityHub IAM.11-17**: Various password complexity requirements
- **AWS Security Best Practices**: Strong password policies for IAM users
- **SOC 2**: Access control requirements
- **NIST**: Password complexity guidelines

### AWS Support Role Control
- **SecurityHub IAM.18**: Ensure a support role has been created to manage incidents with AWS Support
- **CIS AWS Foundations Benchmark 1.17**: Ensure a support role has been created
- **AWS Well-Architected Framework**: Operational excellence and security pillars

## Usage

### Basic Usage (Password Policy Only)

```hcl
module "iam_password_policy" {
  source = "./terraform-aws-iam-password-policy"
}
```

### Complete IAM Configuration (Password Policy + Support Role)

```hcl
module "iam_complete" {
  source = "./terraform-aws-iam-password-policy"

  # IAM Password Policy Settings
  minimum_password_length     = 16
  password_reuse_prevention   = 10
  max_password_age           = 60
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers             = true
  require_symbols             = true
  allow_users_to_change_password = true
  hard_expiry                 = false

  # AWS Support Role Settings (IAM.18)
  create_aws_support_role              = true
  aws_support_role_name                = "CustomSupportRole"
  aws_support_role_trusted_entities    = [
    "arn:aws:iam::123456789012:root",  # Trusted AWS account
    "arn:aws:iam::123456789012:role/SecurityTeam"  # Specific IAM role
  ]
  aws_support_role_require_mfa         = true
  aws_support_role_max_session_duration = 7200  # 2 hours
  aws_support_role_tags = {
    Environment = "production"
    Team        = "security"
  }
}
```

### Support Role Only (Disable Password Policy)

```hcl
module "support_role_only" {
  source = "./terraform-aws-iam-password-policy"

  # Disable password policy
  create = false

  # Enable only Support role (uses current account root by default)
  create_aws_support_role = true
  # aws_support_role_trusted_entities = [] # Optional - defaults to current account root
}
```

### Support Role with Specific Trusted Entities

```hcl
module "support_role_configured" {
  source = "./terraform-aws-iam-password-policy"

  create_aws_support_role = true
  aws_support_role_trusted_entities = [
    "arn:aws:iam::123456789012:role/AdminRole",
    "arn:aws:iam::123456789012:user/support-user"
  ]
}
```

### Strict Security Configuration

```hcl
module "strict_iam_security" {
  source = "./terraform-aws-iam-password-policy"

  # Strict password requirements
  minimum_password_length     = 20 # Very long passwords
  password_reuse_prevention   = 24 # Maximum allowed
  max_password_age           = 30  # Monthly changes
  hard_expiry                = true
  
  # All character types required
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers             = true
  require_symbols             = true
  allow_users_to_change_password = true

  # Strict Support role configuration
  create_aws_support_role              = true
  aws_support_role_name                = "StrictSupportRole"
  aws_support_role_path                = "/security/"
  aws_support_role_max_session_duration = 3600  # 1 hour only
  aws_support_role_require_mfa         = true
  aws_support_role_trusted_entities    = [
    "arn:aws:iam::123456789012:role/SecurityAdmin"
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_role.aws_support_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.aws_support_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

### IAM Password Policy Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create | Whether to create the IAM password policy | `bool` | `true` | no |
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
| create_aws_support_role | Whether to create an AWS Support role for incident management | `bool` | `true` | no |
| aws_support_role_name | The name of the AWS Support role | `string` | `"AWSSupport-IncidentManagement"` | no |
| aws_support_role_path | The path for the AWS Support role | `string` | `"/"` | no |
| aws_support_role_max_session_duration | Maximum session duration (in seconds) for the AWS Support role | `number` | `3600` | no |
| aws_support_role_trusted_entities | List of AWS account ARNs or IAM user/role ARNs that can assume the AWS Support role | `list(string)` | `[]` | no |
| aws_support_role_require_mfa | Whether to require MFA for assuming the AWS Support role | `bool` | `true` | no |
| aws_support_role_tags | A map of tags to apply to the AWS Support role | `map(string)` | See defaults | no |

## Outputs

### IAM Password Policy Outputs

| Name | Description |
|------|-------------|
| password_policy_arn | The ARN of the IAM password policy |
| minimum_password_length | Minimum length to require for IAM user passwords |
| require_lowercase_characters | Whether lowercase characters are required for IAM user passwords |
| require_numbers | Whether numbers are required for IAM user passwords |
| require_uppercase_characters | Whether uppercase characters are required for IAM user passwords |
| require_symbols | Whether symbols are required for IAM user passwords |
| allow_users_to_change_password | Whether users are allowed to change their own password |
| hard_expiry | Whether users are prevented from setting a new password after their password has expired |
| max_password_age | The number of days that an IAM user password is valid |
| password_reuse_prevention | The number of previous passwords that users are prevented from reusing |

### AWS Support Role Outputs (IAM.18)

| Name | Description |
|------|-------------|
| aws_support_role_enabled | Whether AWS Support role is enabled |
| aws_support_role_arn | The ARN of the AWS Support role (if created) |
| aws_support_role_name | The name of the AWS Support role (if created) |
| aws_support_role_unique_id | The unique ID of the AWS Support role (if created) |
| aws_support_role_trusted_entities | List of trusted entities that can assume the AWS Support role |
| aws_support_role_requires_mfa | Whether the AWS Support role requires MFA for assumption |
| iam_compliance_summary | Summary of IAM compliance controls and their status |

## Validation Rules

The module includes comprehensive input validation to ensure:

### Password Policy Validation
- **Password Length**: Between 6 and 128 characters (AWS limits)
- **Password Age**: Between 1 and 1095 days (AWS limits)
- **Password Reuse Prevention**: Between 1 and 24 previous passwords (AWS limits)

### Support Role Validation
- **Role Name**: 1-64 characters, must start with letter, alphanumeric and +=,.@_- only
- **Role Path**: Must start and end with '/', valid path characters only
- **Session Duration**: Between 3600 (1 hour) and 43200 (12 hours) seconds
- **Trusted Entities**: Must be valid AWS ARNs for accounts, users, or roles

## Best Practices Implemented

### IAM Password Policy Best Practices
1. **Strong Password Requirements**
   - **Minimum Length**: 14 characters (exceeds CIS benchmark requirement)
   - **Character Complexity**: Requires all character types (uppercase, lowercase, numbers, symbols)
   - **Password History**: Prevents reuse of last 24 passwords

2. **User Experience**
   - **Self-Service**: Users can change their own passwords
   - **Reasonable Expiration**: 90-day password expiration (configurable)
   - **Soft Expiry**: Users can set new passwords after expiration (configurable)

3. **Security Controls**
   - **Password Reuse Prevention**: Configured to prevent weak password cycling
   - **Validation**: Input validation prevents misconfiguration
   - **Flexibility**: All settings configurable for different security requirements

### AWS Support Role Best Practices (IAM.18)
1. **Principle of Least Privilege**: Role only has AWS Support access permissions
2. **Trusted Entities Control**: Configure only necessary AWS accounts, users, or roles
3. **MFA Enforcement**: Enable MFA requirement for enhanced security
4. **Session Management**: Set appropriate maximum session duration
5. **Regular Auditing**: Monitor role usage through AWS CloudTrail
6. **Documentation**: Clear documentation of who should have access and why

## Important Notes

- **Account-Level Policy**: AWS IAM password policies apply to the entire AWS account
- **Single Policy**: Only one password policy can exist per AWS account
- **Support Role Global**: AWS Support role is account-wide, not region-specific
- **Import Existing**: If a policy already exists, use `terraform import` to manage it
- **IAM Users Only**: Password policy only affects IAM users, not root account or federated users
- **Trusted Entities Required**: You must configure trusted entities for the Support role to be usable

## AWS Support Role Configuration

### Required Setup
```hcl
# Minimum viable configuration for IAM.18 compliance
module "iam_support_role" {
  source = "./terraform-aws-iam-password-policy"
  
  # Disable password policy if not needed
  create = false
  
  # Enable Support role (automatically uses current account root if no trusted entities specified)
  create_aws_support_role = true
  # No need to specify trusted entities - defaults to current account root for security
}
```

### Trusted Entities Default Behavior

When `aws_support_role_trusted_entities` is not specified or is an empty list, the module automatically defaults to allowing the current AWS account root to assume the role:

```
arn:aws:iam::{current-account-id}:root
```

This ensures IAM.18 compliance while maintaining security best practices. The account root can then delegate access to specific users or roles as needed.

### Best Practice Configuration
```hcl
module "iam_support_role_best_practice" {
  source = "./terraform-aws-iam-password-policy"
  
  create_aws_support_role = true
  aws_support_role_name = "SecurityTeam-SupportAccess"
  aws_support_role_path = "/security/"
  aws_support_role_max_session_duration = 7200  # 2 hours
  aws_support_role_require_mfa = true
  
  # Only specific roles and users
  aws_support_role_trusted_entities = [
    "arn:aws:iam::123456789012:role/SecurityAdministrator",
    "arn:aws:iam::123456789012:user/emergency-support-user"
  ]
  
  aws_support_role_tags = {
    Environment = "production"
    Team        = "security"
    Purpose     = "AWS Support access for incident response"
    Compliance  = "SecurityHub-IAM.18"
  }
}
```

## Examples

### Import Existing Password Policy

```bash
terraform import module.iam_password_policy.aws_iam_account_password_policy.this[0] iam-account-password-policy
```

### Testing Password Policy

After applying the module, test with an IAM user:

```bash
# Create test user
aws iam create-user --user-name test-user

# Create login profile (will enforce password policy)
aws iam create-login-profile --user-name test-user --password "TestPassword123!" --password-reset-required
```

### Testing Support Role

Test the Support role assumption:

```bash
# Assume the role
aws sts assume-role \
  --role-arn $(terraform output -raw aws_support_role_arn) \
  --role-session-name "support-access-test"

# Test AWS Support access
aws support describe-cases  # Should work with assumed role
```

## SecurityHub Compliance

After deploying this module:
- **IAM.7, IAM.11-17**: Password policy controls will show as **COMPLIANT**
- **IAM.18**: Support role control will show as **COMPLIANT**
- All IAM password complexity requirements will be enforced
- AWS Support access will be available through the created IAM role

## Troubleshooting

### Common Issues

1. **Password Too Complex**: Users struggle with password requirements
   - Solution: Provide password generation tools and training

2. **Support Role Access**: Cannot assume the Support role
   - Verify trusted entities are correctly formatted as AWS ARNs
   - Check MFA requirements if enabled

3. **Multiple Password Policies**: Error creating password policy
   - AWS allows only one password policy per account
   - Import existing policy or remove conflicting one

### Verification Commands

```bash
# Check password policy
aws iam get-account-password-policy

# Check Support role
aws iam get-role --role-name AWSSupport-IncidentManagement

# Verify SecurityHub compliance
aws securityhub get-findings --filters '{"ComplianceStatus":[{"Value":"FAILED","Comparison":"EQUALS"}],"RecordState":[{"Value":"ACTIVE","Comparison":"EQUALS"}]}'
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for your changes
5. Ensure documentation is updated
6. Submit a pull request

## License

This module is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Authors

Created and maintained by the Infrastructure Team.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history and changes.
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
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_role.aws_support_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.aws_support_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

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
| <a name="input_create"></a> [create](#input\_create) | Whether to create the IAM password policy | `bool` | `true` | no |
| <a name="input_create_aws_support_role"></a> [create\_aws\_support\_role](#input\_create\_aws\_support\_role) | Whether to create an AWS Support role for incident management (SecurityHub IAM.18) | `bool` | `true` | no |
| <a name="input_hard_expiry"></a> [hard\_expiry](#input\_hard\_expiry) | Whether users are prevented from setting a new password after their password has expired (i.e., hard expiry) | `bool` | `false` | no |
| <a name="input_max_password_age"></a> [max\_password\_age](#input\_max\_password\_age) | The number of days that an IAM user password is valid | `number` | `90` | no |
| <a name="input_minimum_password_length"></a> [minimum\_password\_length](#input\_minimum\_password\_length) | Minimum length to require for IAM user passwords | `number` | `14` | no |
| <a name="input_password_reuse_prevention"></a> [password\_reuse\_prevention](#input\_password\_reuse\_prevention) | The number of previous passwords that users are prevented from reusing | `number` | `24` | no |
| <a name="input_require_lowercase_characters"></a> [require\_lowercase\_characters](#input\_require\_lowercase\_characters) | Whether to require lowercase characters for IAM user passwords | `bool` | `true` | no |
| <a name="input_require_numbers"></a> [require\_numbers](#input\_require\_numbers) | Whether to require numbers for IAM user passwords | `bool` | `true` | no |
| <a name="input_require_symbols"></a> [require\_symbols](#input\_require\_symbols) | Whether to require symbols for IAM user passwords | `bool` | `true` | no |
| <a name="input_require_uppercase_characters"></a> [require\_uppercase\_characters](#input\_require\_uppercase\_characters) | Whether to require uppercase characters for IAM user passwords | `bool` | `true` | no |

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
| <a name="output_hard_expiry"></a> [hard\_expiry](#output\_hard\_expiry) | Whether users are prevented from setting a new password after their password has expired |
| <a name="output_iam_compliance_summary"></a> [iam\_compliance\_summary](#output\_iam\_compliance\_summary) | Summary of IAM compliance controls and their status |
| <a name="output_max_password_age"></a> [max\_password\_age](#output\_max\_password\_age) | The number of days that an IAM user password is valid |
| <a name="output_minimum_password_length"></a> [minimum\_password\_length](#output\_minimum\_password\_length) | Minimum length to require for IAM user passwords |
| <a name="output_password_policy_arn"></a> [password\_policy\_arn](#output\_password\_policy\_arn) | The ARN of the IAM password policy |
| <a name="output_password_reuse_prevention"></a> [password\_reuse\_prevention](#output\_password\_reuse\_prevention) | The number of previous passwords that users are prevented from reusing |
| <a name="output_require_lowercase_characters"></a> [require\_lowercase\_characters](#output\_require\_lowercase\_characters) | Whether lowercase characters are required for IAM user passwords |
| <a name="output_require_numbers"></a> [require\_numbers](#output\_require\_numbers) | Whether numbers are required for IAM user passwords |
| <a name="output_require_symbols"></a> [require\_symbols](#output\_require\_symbols) | Whether symbols are required for IAM user passwords |
| <a name="output_require_uppercase_characters"></a> [require\_uppercase\_characters](#output\_require\_uppercase\_characters) | Whether uppercase characters are required for IAM user passwords |
<!-- END_TF_DOCS -->