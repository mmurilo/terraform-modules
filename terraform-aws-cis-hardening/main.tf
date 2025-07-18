# ============================================================================
# AWS CIS Hardening Terraform Module
# 
# This module deploys AWS CIS hardening submodules:
# - IAM Access Analyzer (Account and Organization level)
# - IAM Password Policy (CIS 1.9, 1.10)
# - Security Controls (SecurityHub S3.1, EC2.7)
# ============================================================================

# Get current AWS account information
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Module  = "terraform-aws-cis-hardening"
      Purpose = "CIS-Security-Hardening"
    }
  )

  # Conditional creation flags - IAM password policy is global service, only deploy in us-east-1
  create_iam_access_analyzer = var.create_iam_access_analyzer
  create_iam_password_policy = var.create_iam_password_policy && data.aws_region.current.region == "us-east-1"
  create_security_controls   = var.create_security_controls

  # Account configuration
  current_account_id = data.aws_caller_identity.current.account_id
}

# ============================================================================
# IAM Access Analyzer Module
# ============================================================================

module "iam_access_analyzer" {
  count = local.create_iam_access_analyzer ? 1 : 0

  source = "./modules/iam-access-analyzer"

  # Analyzer Configuration
  analyzer_name = var.iam_access_analyzer_name
  type          = var.iam_access_analyzer_type

  # Unused Access Configuration (for ORGANIZATION_UNUSED_ACCESS type)
  unused_access_configuration = var.iam_access_analyzer_unused_access_configuration

  # Archive Rules
  archive_rules = var.iam_access_analyzer_archive_rules

  tags = local.common_tags
}

# ============================================================================
# Security Controls Module (SecurityHub S3.1, EC2.7)
# ============================================================================

module "security_controls" {
  count = local.create_security_controls ? 1 : 0

  source = "./modules/security-controls"

  # S3 Account Public Access Block (SecurityHub S3.1)
  enable_s3_account_public_access_block = var.security_controls_enable_s3_account_public_access_block
  s3_block_public_acls                  = var.security_controls_s3_block_public_acls
  s3_block_public_policy                = var.security_controls_s3_block_public_policy
  s3_ignore_public_acls                 = var.security_controls_s3_ignore_public_acls
  s3_restrict_public_buckets            = var.security_controls_s3_restrict_public_buckets

  # EBS Encryption (SecurityHub EC2.7)
  enable_ebs_encryption_by_default = var.security_controls_enable_ebs_encryption_by_default
  ebs_encryption_enabled           = var.security_controls_ebs_encryption_enabled
  ebs_kms_key_arn                  = var.security_controls_ebs_kms_key_arn
  create_ebs_kms_key               = var.security_controls_create_ebs_kms_key
  ebs_kms_key_deletion_window      = var.security_controls_ebs_kms_key_deletion_window
  ebs_kms_key_rotation             = var.security_controls_ebs_kms_key_rotation
  ebs_kms_key_alias                = var.security_controls_ebs_kms_key_alias

  tags = local.common_tags
}

# ============================================================================
# IAM Password Policy & Support Role Module (SecurityHub IAM.7, IAM.11-18)
# ============================================================================

module "iam_password_policy" {
  count = local.create_iam_password_policy ? 1 : 0

  source = "./modules/iam-password-policy"

  # IAM Password Policy Settings
  create                         = var.iam_password_policy_create
  minimum_password_length        = var.iam_password_policy_minimum_password_length
  require_lowercase_characters   = var.iam_password_policy_require_lowercase_characters
  require_numbers                = var.iam_password_policy_require_numbers
  require_uppercase_characters   = var.iam_password_policy_require_uppercase_characters
  require_symbols                = var.iam_password_policy_require_symbols
  allow_users_to_change_password = var.iam_password_policy_allow_users_to_change_password
  hard_expiry                    = var.iam_password_policy_hard_expiry
  max_password_age               = var.iam_password_policy_max_password_age
  password_reuse_prevention      = var.iam_password_policy_password_reuse_prevention

  # AWS Support Role Settings (SecurityHub IAM.18)
  create_aws_support_role               = var.iam_password_policy_create_aws_support_role
  aws_support_role_name                 = var.iam_password_policy_aws_support_role_name
  aws_support_role_path                 = var.iam_password_policy_aws_support_role_path
  aws_support_role_max_session_duration = var.iam_password_policy_aws_support_role_max_session_duration
  aws_support_role_trusted_entities     = var.iam_password_policy_aws_support_role_trusted_entities
  aws_support_role_require_mfa          = var.iam_password_policy_aws_support_role_require_mfa
  aws_support_role_tags                 = merge(local.common_tags, var.iam_password_policy_aws_support_role_tags)
}
