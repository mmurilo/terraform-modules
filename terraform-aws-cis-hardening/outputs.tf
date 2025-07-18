# ============================================================================
# AWS CIS Hardening Terraform Module Outputs
# 
# This file exposes all outputs from the submodules:
# - IAM Access Analyzer  
# - IAM Password Policy
# - Security Controls
# ============================================================================

# ============================================================================
# Module Deployment Status
# ============================================================================

output "modules_deployed" {
  description = "Status of which modules were deployed"
  value = {
    iam_access_analyzer = local.create_iam_access_analyzer
    iam_password_policy = local.create_iam_password_policy
    security_controls   = local.create_security_controls
  }
}

output "account_information" {
  description = "AWS account information and configuration"
  value = {
    current_account_id = local.current_account_id
    region             = data.aws_region.current.region
  }
}

# ============================================================================
# IAM Access Analyzer Module Outputs
# ============================================================================

output "iam_access_analyzer" {
  description = "IAM Access Analyzer module outputs"
  value = local.create_iam_access_analyzer ? {
    analyzer_arn  = module.iam_access_analyzer[0].analyzer_arn
    analyzer_id   = module.iam_access_analyzer[0].analyzer_id
    analyzer_name = module.iam_access_analyzer[0].analyzer_name
    analyzer_type = module.iam_access_analyzer[0].analyzer_type
    archive_rules = module.iam_access_analyzer[0].archive_rules
  } : null
}

# Individual IAM Access Analyzer outputs for easier access
output "iam_access_analyzer_arn" {
  description = "ARN of the IAM Access Analyzer (if created)"
  value       = local.create_iam_access_analyzer ? module.iam_access_analyzer[0].analyzer_arn : null
}

output "iam_access_analyzer_name" {
  description = "Name of the IAM Access Analyzer (if created)"
  value       = local.create_iam_access_analyzer ? module.iam_access_analyzer[0].analyzer_name : null
}

# ============================================================================
# IAM Password Policy Module Outputs
# ============================================================================

output "iam_password_policy" {
  description = "IAM Password Policy module outputs"
  value = local.create_iam_password_policy ? {
    # Password Policy
    password_policy_arn            = module.iam_password_policy[0].password_policy_arn
    minimum_password_length        = module.iam_password_policy[0].minimum_password_length
    require_lowercase_characters   = module.iam_password_policy[0].require_lowercase_characters
    require_numbers                = module.iam_password_policy[0].require_numbers
    require_uppercase_characters   = module.iam_password_policy[0].require_uppercase_characters
    require_symbols                = module.iam_password_policy[0].require_symbols
    allow_users_to_change_password = module.iam_password_policy[0].allow_users_to_change_password
    hard_expiry                    = module.iam_password_policy[0].hard_expiry
    max_password_age               = module.iam_password_policy[0].max_password_age
    password_reuse_prevention      = module.iam_password_policy[0].password_reuse_prevention

    # AWS Support Role (IAM.18)
    aws_support_role_enabled          = module.iam_password_policy[0].aws_support_role_enabled
    aws_support_role_arn              = module.iam_password_policy[0].aws_support_role_arn
    aws_support_role_name             = module.iam_password_policy[0].aws_support_role_name
    aws_support_role_unique_id        = module.iam_password_policy[0].aws_support_role_unique_id
    aws_support_role_trusted_entities = module.iam_password_policy[0].aws_support_role_trusted_entities
    aws_support_role_requires_mfa     = module.iam_password_policy[0].aws_support_role_requires_mfa

    # Compliance Summary
    iam_compliance_summary = module.iam_password_policy[0].iam_compliance_summary
  } : null
}

# ============================================================================
# Individual IAM Outputs for Easy Access
# ============================================================================

output "password_policy_arn" {
  description = "ARN of the IAM password policy (if created)"
  value       = local.create_iam_password_policy ? module.iam_password_policy[0].password_policy_arn : null
}

# ============================================================================
# Security Controls Module Outputs
# ============================================================================

output "security_controls" {
  description = "Security Controls module outputs"
  value = local.create_security_controls ? {
    # S3 Account Public Access Block
    s3_account_public_access_block_enabled = module.security_controls[0].s3_account_public_access_block_enabled
    s3_account_public_access_block_id      = module.security_controls[0].s3_account_public_access_block_id
    s3_public_access_settings              = module.security_controls[0].s3_public_access_settings

    # EBS Encryption
    ebs_encryption_by_default_enabled = module.security_controls[0].ebs_encryption_by_default_enabled
    ebs_encryption_by_default_id      = module.security_controls[0].ebs_encryption_by_default_id
    ebs_default_kms_key_arn           = module.security_controls[0].ebs_default_kms_key_arn
    ebs_kms_key_created               = module.security_controls[0].ebs_kms_key_created
    ebs_kms_key_id                    = module.security_controls[0].ebs_kms_key_id
    ebs_kms_key_alias                 = module.security_controls[0].ebs_kms_key_alias

    # Summary
    security_controls_summary = module.security_controls[0].security_controls_summary
  } : null
}

# Individual Security Controls outputs for easier access
output "s3_account_public_access_block_enabled" {
  description = "Whether S3 account public access block is enabled (if created)"
  value       = local.create_security_controls ? module.security_controls[0].s3_account_public_access_block_enabled : null
}

output "ebs_encryption_by_default_enabled" {
  description = "Whether EBS encryption by default is enabled (if created)"
  value       = local.create_security_controls ? module.security_controls[0].ebs_encryption_by_default_enabled : null
}

output "ebs_default_kms_key_arn" {
  description = "ARN of the KMS key used for EBS default encryption (if created)"
  value       = local.create_security_controls ? module.security_controls[0].ebs_default_kms_key_arn : null
}

# ============================================================================
# AWS Support Role Individual Outputs (SecurityHub Control IAM.18)
# ============================================================================

output "aws_support_role_enabled" {
  description = "Whether AWS Support role is enabled (if created)"
  value       = local.create_iam_password_policy ? module.iam_password_policy[0].aws_support_role_enabled : null
}

output "aws_support_role_arn" {
  description = "ARN of the AWS Support role (if created)"
  value       = local.create_iam_password_policy ? module.iam_password_policy[0].aws_support_role_arn : null
}

output "aws_support_role_name" {
  description = "Name of the AWS Support role (if created)"
  value       = local.create_iam_password_policy ? module.iam_password_policy[0].aws_support_role_name : null
}

output "aws_support_role_trusted_entities" {
  description = "List of trusted entities that can assume the AWS Support role (including defaults)"
  value       = local.create_iam_password_policy ? module.iam_password_policy[0].aws_support_role_trusted_entities : null
}

output "aws_support_role_uses_default_trusted_entities" {
  description = "Whether the AWS Support role is using default trusted entities (current account root)"
  value       = local.create_iam_password_policy ? module.iam_password_policy[0].aws_support_role_uses_default_trusted_entities : null
}

# ============================================================================
# Compliance Summary
# ============================================================================

output "compliance_summary" {
  description = "Summary of compliance status for all security controls"
  value = {
    # SecurityHub Controls
    securityhub_controls = {
      "S3.1_block_public_access" = {
        enabled = local.create_security_controls
        status  = local.create_security_controls ? (module.security_controls[0].s3_account_public_access_block_enabled ? "COMPLIANT" : "NON_COMPLIANT") : "NOT_IMPLEMENTED"
        details = "S3 general purpose buckets should have block public access settings enabled"
      }
      "EC2.7_ebs_default_encryption" = {
        enabled = local.create_security_controls
        status  = local.create_security_controls ? (module.security_controls[0].ebs_encryption_by_default_enabled ? "COMPLIANT" : "NON_COMPLIANT") : "NOT_IMPLEMENTED"
        details = "EBS default encryption should be enabled"
      }
      "IAM.18_support_role" = {
        enabled = local.create_iam_password_policy
        status  = local.create_iam_password_policy ? (module.iam_password_policy[0].aws_support_role_enabled ? "COMPLIANT" : "NON_COMPLIANT") : "NOT_IMPLEMENTED"
        details = "Ensure a support role has been created to manage incidents with AWS Support"
      }
    }

    # Overall Status
    overall_status = {
      modules_deployed = length([
        for k, v in {
          iam_access_analyzer = local.create_iam_access_analyzer
          iam_password_policy = local.create_iam_password_policy
          security_controls   = local.create_security_controls
        } : k if v
      ])
      total_modules       = 3
      deployment_complete = local.create_iam_access_analyzer && local.create_iam_password_policy && local.create_security_controls
    }
  }
}

# ============================================================================
# Quick Reference Outputs
# ============================================================================

output "quick_reference" {
  description = "Quick reference for key resources created"
  value = {
    # Key ARNs
    iam_access_analyzer_arn = local.create_iam_access_analyzer ? module.iam_access_analyzer[0].analyzer_arn : null
    password_policy_arn     = local.create_iam_password_policy ? module.iam_password_policy[0].password_policy_arn : null

    # KMS Keys
    ebs_kms_key = local.create_security_controls ? module.security_controls[0].ebs_default_kms_key_arn : null

    # Security Status
    s3_public_access_blocked = local.create_security_controls ? module.security_controls[0].s3_account_public_access_block_enabled : null
    ebs_encryption_enabled   = local.create_security_controls ? module.security_controls[0].ebs_encryption_by_default_enabled : null
  }
}
