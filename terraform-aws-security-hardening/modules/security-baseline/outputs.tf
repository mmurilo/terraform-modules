# ============================================================================
# AWS Security Baseline Module Outputs
# ============================================================================

# ============================================================================
# IAM PASSWORD POLICY Outputs (SecurityHub Controls IAM.7, IAM.11-17)
# ============================================================================

output "iam_password_policy_enabled" {
  description = "Whether IAM password policy is enabled"
  value       = var.enable_iam_password_policy
}

output "password_policy_arn" {
  description = "The ARN of the IAM password policy"
  value       = var.enable_iam_password_policy ? "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:account-password-policy/iam-account-password-policy" : null
}

output "minimum_password_length" {
  description = "Minimum length to require for IAM user passwords"
  value       = var.enable_iam_password_policy ? var.minimum_password_length : null
}

output "require_lowercase_characters" {
  description = "Whether lowercase characters are required for IAM user passwords"
  value       = var.enable_iam_password_policy ? var.require_lowercase_characters : null
}

output "require_numbers" {
  description = "Whether numbers are required for IAM user passwords"
  value       = var.enable_iam_password_policy ? var.require_numbers : null
}

output "require_uppercase_characters" {
  description = "Whether uppercase characters are required for IAM user passwords"
  value       = var.enable_iam_password_policy ? var.require_uppercase_characters : null
}

output "require_symbols" {
  description = "Whether symbols are required for IAM user passwords"
  value       = var.enable_iam_password_policy ? var.require_symbols : null
}

output "allow_users_to_change_password" {
  description = "Whether users are allowed to change their own password"
  value       = var.enable_iam_password_policy ? var.allow_users_to_change_password : null
}

output "hard_expiry" {
  description = "Whether users are prevented from setting a new password after their password has expired"
  value       = var.enable_iam_password_policy ? var.hard_expiry : null
}

output "max_password_age" {
  description = "The number of days that an IAM user password is valid"
  value       = var.enable_iam_password_policy ? var.max_password_age : null
}

output "password_reuse_prevention" {
  description = "The number of previous passwords that users are prevented from reusing"
  value       = var.enable_iam_password_policy ? var.password_reuse_prevention : null
}

# ============================================================================
# AWS SUPPORT ROLE Outputs (SecurityHub Control IAM.18)
# ============================================================================

output "aws_support_role_enabled" {
  description = "Whether AWS Support role is enabled"
  value       = var.enable_aws_support_role
}

output "aws_support_role_arn" {
  description = "The ARN of the AWS Support role (if created)"
  value       = var.enable_aws_support_role ? try(aws_iam_role.aws_support_role[0].arn, null) : null
}

output "aws_support_role_name" {
  description = "The name of the AWS Support role (if created)"
  value       = var.enable_aws_support_role ? try(aws_iam_role.aws_support_role[0].name, null) : null
}

output "aws_support_role_unique_id" {
  description = "The unique ID of the AWS Support role (if created)"
  value       = var.enable_aws_support_role ? try(aws_iam_role.aws_support_role[0].unique_id, null) : null
}

output "aws_support_role_trusted_entities" {
  description = "List of trusted entities that can assume the AWS Support role"
  value       = var.enable_aws_support_role ? local.support_role_trusted_entities : null
}

output "aws_support_role_requires_mfa" {
  description = "Whether the AWS Support role requires MFA for assumption"
  value       = var.enable_aws_support_role ? var.aws_support_role_require_mfa : null
}

output "aws_support_role_uses_default_trusted_entities" {
  description = "Whether the AWS Support role is using default trusted entities (current account root)"
  value       = var.enable_aws_support_role ? length(var.aws_support_role_trusted_entities) == 0 : null
}

# ============================================================================
# IAM ACCESS ANALYZER Outputs (SecurityHub Control IAM.28)
# ============================================================================

output "iam_access_analyzer_enabled" {
  description = "Whether IAM Access Analyzer is enabled"
  value       = var.enable_iam_access_analyzer
}

output "iam_access_analyzer_arn" {
  description = "The ARN of the IAM Access Analyzer (if created)"
  value       = var.enable_iam_access_analyzer ? try(aws_accessanalyzer_analyzer.external[0].arn, null) : null
}

output "iam_access_analyzer_name" {
  description = "The name of the IAM Access Analyzer (if created)"
  value       = var.enable_iam_access_analyzer ? try(aws_accessanalyzer_analyzer.external[0].analyzer_name, null) : null
}

output "iam_access_analyzer_type" {
  description = "The type of the IAM Access Analyzer (if created)"
  value       = var.enable_iam_access_analyzer ? try(aws_accessanalyzer_analyzer.external[0].type, null) : null
}

output "iam_access_analyzer_archive_rules" {
  description = "Map of created archive rules for the IAM Access Analyzer"
  value = var.enable_iam_access_analyzer ? {
    for rule_name, rule in aws_accessanalyzer_archive_rule.this : rule_name => {
      id            = rule.id
      analyzer_name = rule.analyzer_name
      rule_name     = rule.rule_name
    }
  } : {}
}

output "iam_access_analyzer_unused_access_configuration" {
  description = "The unused access configuration for the IAM Access Analyzer (if configured)"
  value       = var.enable_iam_access_analyzer && var.iam_access_analyzer_type == "ORGANIZATION_UNUSED_ACCESS" ? var.iam_access_analyzer_unused_access_configuration : null
}

output "iam_access_analyzer_iam28_compliant" {
  description = "Whether the IAM Access Analyzer is compliant with SecurityHub IAM.28 control (requires external access analyzer)"
  value       = var.enable_iam_access_analyzer ? contains(["ACCOUNT", "ORGANIZATION"], var.iam_access_analyzer_type) : false
}

# ============================================================================
# S3 ACCOUNT PUBLIC ACCESS BLOCK Outputs (SecurityHub Control S3.1)
# ============================================================================

output "s3_account_public_access_block_enabled" {
  description = "Whether S3 account public access block is enabled"
  value       = var.enable_s3_account_public_access_block
}

output "s3_account_public_access_block_id" {
  description = "The account ID for which the S3 account public access block configuration is applied"
  value       = var.enable_s3_account_public_access_block ? try(aws_s3_account_public_access_block.this[0].id, null) : null
}

output "s3_public_access_settings" {
  description = "Current S3 public access block settings"
  value = var.enable_s3_account_public_access_block ? {
    block_public_acls       = var.s3_block_public_acls
    block_public_policy     = var.s3_block_public_policy
    ignore_public_acls      = var.s3_ignore_public_acls
    restrict_public_buckets = var.s3_restrict_public_buckets
  } : null
}

# ============================================================================
# EBS ENCRYPTION Outputs (SecurityHub Control EC2.7)
# ============================================================================

output "ebs_encryption_by_default_enabled" {
  description = "Whether EBS encryption by default is enabled"
  value       = var.enable_ebs_encryption_by_default
}

output "ebs_encryption_by_default_id" {
  description = "The region where EBS encryption by default is configured"
  value       = var.enable_ebs_encryption_by_default ? try(aws_ebs_encryption_by_default.this[0].id, null) : null
}

output "ebs_default_kms_key_arn" {
  description = "The ARN of the KMS key used for EBS default encryption"
  value = var.enable_ebs_encryption_by_default ? (
    var.create_ebs_kms_key ? try(aws_kms_key.ebs_encryption[0].arn, null) : var.ebs_kms_key_arn
  ) : null
}

output "ebs_kms_key_created" {
  description = "Whether a new KMS key was created for EBS encryption"
  value       = var.enable_ebs_encryption_by_default && var.create_ebs_kms_key
}

output "ebs_kms_key_id" {
  description = "The ID of the created KMS key for EBS encryption (if created)"
  value       = var.enable_ebs_encryption_by_default && var.create_ebs_kms_key ? try(aws_kms_key.ebs_encryption[0].key_id, null) : null
}

output "ebs_kms_key_alias" {
  description = "The alias of the created KMS key for EBS encryption (if created)"
  value       = var.enable_ebs_encryption_by_default && var.create_ebs_kms_key ? var.ebs_kms_key_alias : null
}

# ============================================================================
# SECURITY CONTROLS COMPLIANCE SUMMARY
# ============================================================================

output "security_controls_summary" {
  description = "Summary of deployed security controls and their compliance status"
  value = {
    securityhub_controls = {
      "IAM.7" = {
        description = "IAM password policies for IAM users should have strong configurations"
        enabled     = var.enable_iam_password_policy
        status      = var.enable_iam_password_policy ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "IAM.11" = {
        description = "Ensure IAM password policy requires at least one uppercase letter"
        enabled     = var.enable_iam_password_policy && var.require_uppercase_characters
        status      = (var.enable_iam_password_policy && var.require_uppercase_characters) ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "IAM.12" = {
        description = "Ensure IAM password policy requires at least one lowercase letter"
        enabled     = var.enable_iam_password_policy && var.require_lowercase_characters
        status      = (var.enable_iam_password_policy && var.require_lowercase_characters) ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "IAM.13" = {
        description = "Ensure IAM password policy requires at least one symbol"
        enabled     = var.enable_iam_password_policy && var.require_symbols
        status      = (var.enable_iam_password_policy && var.require_symbols) ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "IAM.14" = {
        description = "Ensure IAM password policy requires at least one number"
        enabled     = var.enable_iam_password_policy && var.require_numbers
        status      = (var.enable_iam_password_policy && var.require_numbers) ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "IAM.15" = {
        description = "Ensure IAM password policy requires minimum length of 14 or greater"
        enabled     = var.enable_iam_password_policy && var.minimum_password_length >= 14
        status      = (var.enable_iam_password_policy && var.minimum_password_length >= 14) ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "IAM.16" = {
        description = "Ensure IAM password policy prevents password reuse"
        enabled     = var.enable_iam_password_policy && var.password_reuse_prevention > 0
        status      = (var.enable_iam_password_policy && var.password_reuse_prevention > 0) ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "IAM.17" = {
        description = "Ensure IAM password policy expires passwords within 90 days or less"
        enabled     = var.enable_iam_password_policy && var.max_password_age <= 90
        status      = (var.enable_iam_password_policy && var.max_password_age <= 90) ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "IAM.18" = {
        description = "Ensure a support role has been created to manage incidents with AWS Support"
        enabled     = var.enable_aws_support_role
        status      = var.enable_aws_support_role ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "IAM.28" = {
        description = "IAM Access Analyzer external access analyzer should be enabled"
        enabled     = var.enable_iam_access_analyzer
        status      = var.enable_iam_access_analyzer ? (contains(["ACCOUNT", "ORGANIZATION"], var.iam_access_analyzer_type) ? "COMPLIANT" : "NON_COMPLIANT") : "NOT_IMPLEMENTED"
      }
      "S3.1" = {
        description = "S3 general purpose buckets should have block public access settings enabled"
        enabled     = var.enable_s3_account_public_access_block
        status      = var.enable_s3_account_public_access_block ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
      "EC2.7" = {
        description = "EBS default encryption should be enabled"
        enabled     = var.enable_ebs_encryption_by_default
        status      = var.enable_ebs_encryption_by_default ? "COMPLIANT" : "NOT_IMPLEMENTED"
      }
    }
    deployment_details = {
      aws_account_id = data.aws_caller_identity.current.account_id
      aws_region     = data.aws_region.current.region
      aws_partition  = data.aws_partition.current.partition
      module_version = "1.0.0"
    }
  }
}

# ============================================================================
# MODULE CONFIGURATION SUMMARY
# ============================================================================

output "module_configuration" {
  description = "Module configuration details for debugging and validation"
  value = {
    iam_password_policy = {
      enabled                        = var.enable_iam_password_policy
      minimum_password_length        = var.minimum_password_length
      require_lowercase_characters   = var.require_lowercase_characters
      require_uppercase_characters   = var.require_uppercase_characters
      require_numbers                = var.require_numbers
      require_symbols                = var.require_symbols
      allow_users_to_change_password = var.allow_users_to_change_password
      hard_expiry                    = var.hard_expiry
      max_password_age               = var.max_password_age
      password_reuse_prevention      = var.password_reuse_prevention
    }
    aws_support_role = {
      enabled                       = var.enable_aws_support_role
      name                          = var.aws_support_role_name
      path                          = var.aws_support_role_path
      max_session_duration          = var.aws_support_role_max_session_duration
      trusted_entities_count        = length(var.aws_support_role_trusted_entities)
      requires_mfa                  = var.aws_support_role_require_mfa
      uses_default_trusted_entities = length(var.aws_support_role_trusted_entities) == 0
    }
    iam_access_analyzer = {
      enabled                     = var.enable_iam_access_analyzer
      analyzer_name               = var.iam_access_analyzer_name
      type                        = var.iam_access_analyzer_type
      iam28_compliant             = var.enable_iam_access_analyzer ? contains(["ACCOUNT", "ORGANIZATION"], var.iam_access_analyzer_type) : false
      unused_access_configuration = var.iam_access_analyzer_unused_access_configuration
      archive_rules_count         = length(var.iam_access_analyzer_archive_rules)
    }
    s3_settings = {
      enabled                 = var.enable_s3_account_public_access_block
      block_public_acls       = var.s3_block_public_acls
      block_public_policy     = var.s3_block_public_policy
      ignore_public_acls      = var.s3_ignore_public_acls
      restrict_public_buckets = var.s3_restrict_public_buckets
    }
    ebs_settings = {
      encryption_enabled   = var.enable_ebs_encryption_by_default
      create_kms_key       = var.create_ebs_kms_key
      kms_key_arn          = var.ebs_kms_key_arn
      kms_key_alias        = var.ebs_kms_key_alias
      key_rotation_enabled = var.ebs_kms_key_rotation
      key_deletion_window  = var.ebs_kms_key_deletion_window
    }
  }
}
