# Strict Security IAM Password Policy Example

This example demonstrates the advanced usage of the AWS IAM Password Policy Terraform module with maximum security settings suitable for high-security environments, government agencies, or organizations with strict compliance requirements.

## What This Example Creates

This example creates an AWS IAM password policy with the following strict security configurations:

- **Minimum Password Length**: 20 characters (exceeds all compliance frameworks)
- **Character Requirements**: Requires all character types (uppercase, lowercase, numbers, symbols)
- **Password Reuse Prevention**: Prevents reuse of last 24 passwords (AWS maximum)
- **Password Expiration**: 30 days (monthly password changes)
- **Hard Expiry**: Enabled - Users cannot set new passwords after expiration without admin intervention
- **User Self-Service**: Allows users to change their own passwords before expiration

## Security Benefits

This configuration provides:

- **Maximum Password Complexity**: 20-character requirement with all character types
- **Enhanced History Protection**: 24-password history prevents password cycling
- **Frequent Password Changes**: Monthly rotation reduces exposure window
- **Strict Expiration**: Hard expiry prevents password usage beyond expiration
- **Compliance Excellence**: Exceeds requirements for most security frameworks

## Compliance Standards Met

- ✅ **CIS AWS Foundations Benchmark 1.9**: Password length ≥ 14 characters
- ✅ **CIS AWS Foundations Benchmark 1.10**: Password reuse prevention
- ✅ **NIST SP 800-63B**: Password complexity requirements
- ✅ **SOC 2**: Access control and password management
- ✅ **ISO 27001**: Information security management
- ✅ **FedRAMP**: Federal security requirements
- ✅ **HIPAA**: Healthcare data protection standards

## Usage

1. Navigate to this example:
   ```bash
   cd examples/strict-security
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the strict configuration:
   ```bash
   terraform apply
   ```

5. View the strict policy configuration and compliance status:
   ```bash
   terraform output strict_password_policy_summary
   terraform output compliance_summary
   ```

## Expected Output

After applying, you should see output similar to:

### Password Policy Configuration
```json
{
  "allow_users_to_change_password" = true
  "hard_expiry" = true
  "max_password_age" = 30
  "minimum_password_length" = 20
  "password_reuse_prevention" = 24
  "require_lowercase_characters" = true
  "require_numbers" = true
  "require_symbols" = true
  "require_uppercase_characters" = true
}
```

### Compliance Summary
```json
{
  "cis_benchmark_1_9_compliant" = true
  "cis_benchmark_1_10_compliant" = true
  "maximum_password_history" = true
  "nist_compliant_complexity" = true
  "password_length_exceeds_minimum" = true
}
```

## Testing the Strict Password Policy

Test the strict policy with various password scenarios:

```bash
# Create a test user
aws iam create-user --user-name test-strict-policy-user

# Test 1: Try a password that's too short (should fail)
aws iam create-login-profile \
  --user-name test-strict-policy-user \
  --password "Short123!" \
  --password-reset-required

# Test 2: Try a password without symbols (should fail)
aws iam create-login-profile \
  --user-name test-strict-policy-user \
  --password "LongPasswordWithoutSymbols123" \
  --password-reset-required

# Test 3: Use a compliant 20+ character password (should succeed)
aws iam create-login-profile \
  --user-name test-strict-policy-user \
  --password "SuperSecurePassword123!@#$%^&*()" \
  --password-reset-required
```

## Example Strong Passwords

Here are examples of passwords that meet the strict policy requirements:

- `MyVerySecurePassword2024!@#$%`
- `Enterprise$Security#2024!Strong`
- `CompliantPassword!2024@#$%^&`
- `StrictSecurity#Policy$2024!@#`

## Implementation Considerations

### User Communication
Before implementing this strict policy:

1. **Notify Users**: Inform users about the new password requirements
2. **Provide Guidelines**: Share password creation best practices
3. **Training**: Educate users on password managers
4. **Grace Period**: Consider a transition period for existing users

### Operational Impact

- **Increased Support Requests**: Users may need help with password resets
- **Password Manager Necessity**: Users will likely need password management tools
- **Frequent Changes**: 30-day expiration requires regular password updates
- **Hard Expiry**: Administrators must handle expired account recoveries

### Recommended Complementary Controls

1. **Multi-Factor Authentication (MFA)**: Enable MFA for all IAM users
2. **Password Managers**: Provide organizational password management solutions
3. **Account Monitoring**: Implement login monitoring and anomaly detection
4. **Regular Audits**: Conduct periodic access reviews

## Clean Up

To remove the strict password policy:

```bash
terraform destroy
```

**Warning**: This will revert to no password policy. Ensure you have an alternative policy in place.

## Files

- `main.tf` - Strict security Terraform configuration
- `README.md` - This documentation

## Advanced Configuration Options

You can further customize this example by modifying:

```hcl
# Even stricter settings (if needed)
module "ultra_strict_iam_password_policy" {
  source = "../../"

  minimum_password_length     = 32   # Ultra-long passwords
  password_reuse_prevention   = 24   # Maximum history
  max_password_age           = 15    # Bi-weekly changes
  hard_expiry                = true  # Strict enforcement
  
  # All complexity requirements
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers             = true
  require_symbols             = true
  
  allow_users_to_change_password = true
}
```

## Troubleshooting

### Common Issues

1. **Password Too Complex**: Users struggle with 20+ character requirements
   - Solution: Provide password generation tools and training

2. **Frequent Lockouts**: Hard expiry causes account lockouts
   - Solution: Implement automated password expiration notifications

3. **Password Manager Integration**: Corporate tools may need configuration
   - Solution: Work with IT to configure enterprise password managers

### Support Scripts

Create helper scripts for common operations:

```bash
# Check current password policy
aws iam get-account-password-policy

# List users needing password reset
aws iam list-users --query 'Users[?PasswordLastUsed==null].UserName'
```

## Security Considerations

- **Backup Access**: Ensure administrative access for password resets
- **Emergency Procedures**: Have processes for urgent access needs
- **Monitoring**: Log and monitor password policy violations
- **Regular Reviews**: Periodically assess policy effectiveness 