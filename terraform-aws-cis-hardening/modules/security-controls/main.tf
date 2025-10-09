# ============================================================================
# AWS Security Controls Module
# Addresses SecurityHub Controls:
# - [S3.1] S3 general purpose buckets should have block public access settings enabled
# - [EC2.7] EBS default encryption should be enabled
# ============================================================================

# ============================================================================
# S3 Account Public Access Block (SecurityHub Control S3.1)
# ============================================================================

resource "aws_s3_account_public_access_block" "security_control" {
  count = var.enable_s3_account_public_access_block ? 1 : 0

  block_public_acls       = var.s3_block_public_acls
  block_public_policy     = var.s3_block_public_policy
  ignore_public_acls      = var.s3_ignore_public_acls
  restrict_public_buckets = var.s3_restrict_public_buckets


}

# ============================================================================
# EBS Default Encryption (SecurityHub Control EC2.7)
# ============================================================================

resource "aws_ebs_encryption_by_default" "security_control" {
  count = var.enable_ebs_encryption_by_default ? 1 : 0

  enabled = var.ebs_encryption_enabled


}

# ============================================================================
# EBS Default KMS Key (Optional - enhances EC2.7 control)
# ============================================================================

resource "aws_ebs_default_kms_key" "security_control" {
  count = var.enable_ebs_encryption_by_default && var.ebs_kms_key_arn != null ? 1 : 0

  key_arn = var.ebs_kms_key_arn

  depends_on = [aws_ebs_encryption_by_default.security_control]
}

# ============================================================================
# Optional: Create dedicated KMS key for EBS encryption
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
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
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
    Name        = "security-controls-ebs-kms-key"
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

# ============================================================================
# Data Sources
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================================
# Locals for conditional KMS key ARN
# ============================================================================

locals {
  ebs_kms_key_arn = var.create_ebs_kms_key && var.enable_ebs_encryption_by_default ? aws_kms_key.ebs_encryption[0].arn : var.ebs_kms_key_arn
}

# Set the created KMS key as default if we created one
resource "aws_ebs_default_kms_key" "created_key" {
  count = var.enable_ebs_encryption_by_default && var.create_ebs_kms_key ? 1 : 0

  key_arn = aws_kms_key.ebs_encryption[0].arn

  depends_on = [
    aws_ebs_encryption_by_default.security_control,
    aws_kms_key.ebs_encryption
  ]
}
