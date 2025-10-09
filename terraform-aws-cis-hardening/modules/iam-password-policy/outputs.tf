output "password_policy_arn" {
  description = "The ARN of the IAM password policy"
  value       = var.create ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:account-password-policy/iam-account-password-policy" : null
}

output "minimum_password_length" {
  description = "Minimum length to require for IAM user passwords"
  value       = var.create ? aws_iam_account_password_policy.this[0].minimum_password_length : null
}

output "require_lowercase_characters" {
  description = "Whether lowercase characters are required for IAM user passwords"
  value       = var.create ? aws_iam_account_password_policy.this[0].require_lowercase_characters : null
}

output "require_numbers" {
  description = "Whether numbers are required for IAM user passwords"
  value       = var.create ? aws_iam_account_password_policy.this[0].require_numbers : null
}

output "require_uppercase_characters" {
  description = "Whether uppercase characters are required for IAM user passwords"
  value       = var.create ? aws_iam_account_password_policy.this[0].require_uppercase_characters : null
}

output "require_symbols" {
  description = "Whether symbols are required for IAM user passwords"
  value       = var.create ? aws_iam_account_password_policy.this[0].require_symbols : null
}

output "allow_users_to_change_password" {
  description = "Whether users are allowed to change their own password"
  value       = var.create ? aws_iam_account_password_policy.this[0].allow_users_to_change_password : null
}

output "hard_expiry" {
  description = "Whether users are prevented from setting a new password after their password has expired"
  value       = var.create ? aws_iam_account_password_policy.this[0].hard_expiry : null
}

output "max_password_age" {
  description = "The number of days that an IAM user password is valid"
  value       = var.create ? aws_iam_account_password_policy.this[0].max_password_age : null
}

output "password_reuse_prevention" {
  description = "The number of previous passwords that users are prevented from reusing"
  value       = var.create ? aws_iam_account_password_policy.this[0].password_reuse_prevention : null
}

# ============================================================================
# AWS Support Role Outputs (SecurityHub Control IAM.18)
# ============================================================================

output "aws_support_role_enabled" {
  description = "Whether AWS Support role is enabled"
  value       = var.create_aws_support_role
}

output "aws_support_role_arn" {
  description = "The ARN of the AWS Support role (if created)"
  value       = var.create_aws_support_role ? try(aws_iam_role.aws_support_role[0].arn, null) : null
}

output "aws_support_role_name" {
  description = "The name of the AWS Support role (if created)"
  value       = var.create_aws_support_role ? try(aws_iam_role.aws_support_role[0].name, null) : null
}

output "aws_support_role_unique_id" {
  description = "The unique ID of the AWS Support role (if created)"
  value       = var.create_aws_support_role ? try(aws_iam_role.aws_support_role[0].unique_id, null) : null
}

output "aws_support_role_trusted_entities" {
  description = "List of trusted entities that can assume the AWS Support role"
  value       = var.create_aws_support_role ? local.support_role_trusted_entities : null
}

output "aws_support_role_requires_mfa" {
  description = "Whether the AWS Support role requires MFA for assumption"
  value       = var.create_aws_support_role ? var.aws_support_role_require_mfa : null
}

output "aws_support_role_uses_default_trusted_entities" {
  description = "Whether the AWS Support role is using default trusted entities (current account root)"
  value       = var.create_aws_support_role ? length(var.aws_support_role_trusted_entities) == 0 : null
}

# ============================================================================
# Compliance Summary
# ============================================================================

output "iam_compliance_summary" {
  description = "Summary of IAM compliance controls and their status"
  value = {
    password_policy = {
      enabled     = var.create
      compliant   = var.create
      description = "IAM password policy with security best practices"
    }
    support_role = {
      enabled     = var.create_aws_support_role
      compliant   = var.create_aws_support_role
      description = "AWS Support role for incident management (IAM.18)"
    }
    deployment_details = {
      aws_account_id = data.aws_caller_identity.current.account_id
      module_version = "1.0.0"
    }
  }
}
