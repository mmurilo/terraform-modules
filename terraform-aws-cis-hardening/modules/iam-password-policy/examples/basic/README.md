# Basic IAM Password Policy Example

This example demonstrates the basic usage of the AWS IAM Password Policy Terraform module with default security settings.

## What This Example Creates

This example creates an AWS IAM password policy with the following default configurations:

- **Minimum Password Length**: 14 characters
- **Character Requirements**: Requires uppercase, lowercase, numbers, and symbols
- **Password Reuse Prevention**: Prevents reuse of last 5 passwords
- **Password Expiration**: 90 days
- **User Self-Service**: Allows users to change their own passwords
- **Soft Expiry**: Users can set new passwords after expiration

## Usage

1. Clone this repository and navigate to this example:
   ```bash
   cd examples/basic
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the deployment:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. View the password policy configuration:
   ```bash
   terraform output password_policy_summary
   ```

## Expected Output

After applying, you should see output similar to:

```json
{
  "allow_users_to_change_password" = true
  "hard_expiry" = false
  "max_password_age" = 90
  "minimum_password_length" = 14
  "password_reuse_prevention" = 5
  "require_lowercase_characters" = true
  "require_numbers" = true
  "require_symbols" = true
  "require_uppercase_characters" = true
}
```

## Testing the Password Policy

After applying the module, you can test the password policy by creating an IAM user:

```bash
# Create a test user
aws iam create-user --user-name test-password-policy-user

# Try to create a login profile with a weak password (this should fail)
aws iam create-login-profile \
  --user-name test-password-policy-user \
  --password "weak" \
  --password-reset-required

# Create a login profile with a strong password (this should succeed)
aws iam create-login-profile \
  --user-name test-password-policy-user \
  --password "StrongPassword123!@#" \
  --password-reset-required
```

## Clean Up

To destroy the resources created by this example:

```bash
terraform destroy
```

**Note**: Remember to clean up any test IAM users you created during testing.

## Files

- `main.tf` - Main Terraform configuration
- `README.md` - This file

## Requirements

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- AWS Provider >= 5.0

## Permissions Required

The IAM user or role running this Terraform configuration needs the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetAccountPasswordPolicy",
        "iam:UpdateAccountPasswordPolicy",
        "iam:DeleteAccountPasswordPolicy"
      ],
      "Resource": "*"
    }
  ]
}
``` 