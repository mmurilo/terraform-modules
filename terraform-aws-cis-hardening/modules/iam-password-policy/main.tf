data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# ============================================================================
# Local values for IAM Support Role
# ============================================================================

locals {
  # If no trusted entities are provided, default to current account root
  # This follows AWS security best practices for IAM.18 compliance
  support_role_trusted_entities = length(var.aws_support_role_trusted_entities) > 0 ? var.aws_support_role_trusted_entities : [
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}

# ============================================================================
# IAM Password Policy (SecurityHub Controls IAM.7, IAM.11-17)
# ============================================================================

resource "aws_iam_account_password_policy" "this" {
  count = var.create ? 1 : 0

  # Core password requirements
  minimum_password_length      = var.minimum_password_length
  require_lowercase_characters = var.require_lowercase_characters
  require_numbers              = var.require_numbers
  require_uppercase_characters = var.require_uppercase_characters
  require_symbols              = var.require_symbols

  # Password management
  allow_users_to_change_password = var.allow_users_to_change_password
  hard_expiry                    = var.hard_expiry
  max_password_age               = var.max_password_age
  password_reuse_prevention      = var.password_reuse_prevention
}

# ============================================================================
# AWS Support Role (SecurityHub Control IAM.18)
# ============================================================================

resource "aws_iam_role" "aws_support_role" {
  count = var.create_aws_support_role ? 1 : 0

  name                 = var.aws_support_role_name
  max_session_duration = var.aws_support_role_max_session_duration
  path                 = var.aws_support_role_path

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

  tags = var.aws_support_role_tags
}

resource "aws_iam_role_policy_attachment" "aws_support_access" {
  count = var.create_aws_support_role ? 1 : 0

  role       = aws_iam_role.aws_support_role[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSSupportAccess"
}
