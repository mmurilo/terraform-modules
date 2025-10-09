# ============================================================================
# AWS Security Baseline Terraform Module
# Combines fundamental security controls for AWS account hardening
# 
# Security Controls Addressed:
# - [IAM.7, IAM.11-17] IAM password policies for strong authentication
# - [IAM.18] AWS Support role for incident management
# - [IAM.28] IAM Access Analyzer external access analyzer enabled
# - [S3.1] S3 account public access block configuration
# - [EC2.7] EBS default encryption enablement
# ============================================================================

# ============================================================================
# Data Sources
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

# ============================================================================
# Local Variables
# ============================================================================

locals {
  # Support role trusted entities - default to current account root if none provided
  support_role_trusted_entities = length(var.aws_support_role_trusted_entities) > 0 ? var.aws_support_role_trusted_entities : [
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
  ]

  # Determine KMS key ARN for EBS encryption
  ebs_kms_key_arn = var.create_ebs_kms_key && var.enable_ebs_encryption_by_default ? aws_kms_key.ebs_encryption[0].arn : var.ebs_kms_key_arn
}

# ============================================================================
# IAM PASSWORD POLICY (SecurityHub Controls IAM.7, IAM.11-17)
# ============================================================================

resource "aws_iam_account_password_policy" "this" {
  count = var.enable_iam_password_policy ? 1 : 0

  # Core password requirements
  minimum_password_length      = var.minimum_password_length
  require_lowercase_characters = var.require_lowercase_characters
  require_numbers              = var.require_numbers
  require_uppercase_characters = var.require_uppercase_characters
  require_symbols              = var.require_symbols

  # Password management settings
  allow_users_to_change_password = var.allow_users_to_change_password
  hard_expiry                    = var.hard_expiry
  max_password_age               = var.max_password_age
  password_reuse_prevention      = var.password_reuse_prevention
}

# ============================================================================
# AWS SUPPORT ROLE (SecurityHub Control IAM.18)
# ============================================================================

resource "aws_iam_role" "aws_support_role" {
  count = var.enable_aws_support_role ? 1 : 0

  name                 = var.aws_support_role_name
  path                 = var.aws_support_role_path
  max_session_duration = var.aws_support_role_max_session_duration

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = local.support_role_trusted_entities
        }
        Action = "sts:AssumeRole"
        Condition = var.aws_support_role_require_mfa ? {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        } : {}
      }
    ]
  })

  tags = merge(var.tags, var.aws_support_role_tags)
}

resource "aws_iam_role_policy_attachment" "aws_support_access" {
  count = var.enable_aws_support_role ? 1 : 0

  role       = aws_iam_role.aws_support_role[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSSupportAccess"
}

# ============================================================================
# IAM ACCESS ANALYZER (SecurityHub Control IAM.28)
# ============================================================================

resource "aws_accessanalyzer_analyzer" "external" {
  count = var.enable_iam_access_analyzer ? 1 : 0

  analyzer_name = var.iam_access_analyzer_name
  type          = var.iam_access_analyzer_type

  # Dynamic configuration for unused access analyzer
  dynamic "configuration" {
    for_each = var.iam_access_analyzer_type == "ORGANIZATION_UNUSED_ACCESS" && var.iam_access_analyzer_unused_access_configuration != null ? [var.iam_access_analyzer_unused_access_configuration] : []
    content {
      unused_access {
        unused_access_age = configuration.value.unused_access_age

        # Dynamic analysis rule configuration
        dynamic "analysis_rule" {
          for_each = configuration.value.analysis_rule != null ? [configuration.value.analysis_rule] : []
          content {
            # Dynamic exclusion rules
            dynamic "exclusion" {
              for_each = analysis_rule.value.exclusion != null ? analysis_rule.value.exclusion : []
              content {
                account_ids   = exclusion.value.account_ids
                resource_tags = exclusion.value.resource_tags
              }
            }
          }
        }
      }
    }
  }

  tags = merge(var.tags, var.iam_access_analyzer_tags)
}

# ============================================================================
# IAM ACCESS ANALYZER ARCHIVE RULES
# ============================================================================

resource "aws_accessanalyzer_archive_rule" "this" {
  for_each = var.enable_iam_access_analyzer ? var.iam_access_analyzer_archive_rules : {}

  analyzer_name = aws_accessanalyzer_analyzer.external[0].analyzer_name
  rule_name     = each.key

  dynamic "filter" {
    for_each = each.value.filters
    content {
      criteria = filter.value.criteria
      contains = filter.value.contains
      eq       = filter.value.eq
      exists   = filter.value.exists
      neq      = filter.value.neq
    }
  }
}

# ============================================================================
# S3 ACCOUNT PUBLIC ACCESS BLOCK (SecurityHub Control S3.1)
# ============================================================================

resource "aws_s3_account_public_access_block" "this" {
  count = var.enable_s3_account_public_access_block ? 1 : 0

  block_public_acls       = var.s3_block_public_acls
  block_public_policy     = var.s3_block_public_policy
  ignore_public_acls      = var.s3_ignore_public_acls
  restrict_public_buckets = var.s3_restrict_public_buckets
}

# ============================================================================
# EBS DEFAULT ENCRYPTION (SecurityHub Control EC2.7)
# ============================================================================

resource "aws_ebs_encryption_by_default" "this" {
  count = var.enable_ebs_encryption_by_default ? 1 : 0

  enabled = var.ebs_encryption_enabled
}

# ============================================================================
# EBS DEFAULT KMS KEY (Optional - enhances EC2.7 control)
# ============================================================================

resource "aws_ebs_default_kms_key" "this" {
  count = var.enable_ebs_encryption_by_default && local.ebs_kms_key_arn != null ? 1 : 0

  key_arn = local.ebs_kms_key_arn

  depends_on = [aws_ebs_encryption_by_default.this]
}

# ============================================================================
# OPTIONAL: Create dedicated KMS key for EBS encryption
# ============================================================================

resource "aws_kms_key" "ebs_encryption" {
  count = var.enable_ebs_encryption_by_default && var.create_ebs_kms_key ? 1 : 0

  description             = "KMS key for EBS volume encryption - SecurityHub EC2.7 compliance"
  deletion_window_in_days = var.ebs_kms_key_deletion_window
  enable_key_rotation     = var.ebs_kms_key_rotation

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key for EBS"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ec2.${data.aws_region.current.region}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "security-baseline-ebs-kms-key"
    SecurityHub = "EC2.7"
    Purpose     = "KMS key for EBS default encryption"
    ManagedBy   = "terraform"
  })
}

resource "aws_kms_alias" "ebs_encryption" {
  count = var.enable_ebs_encryption_by_default && var.create_ebs_kms_key ? 1 : 0

  name          = var.ebs_kms_key_alias
  target_key_id = aws_kms_key.ebs_encryption[0].key_id
}
