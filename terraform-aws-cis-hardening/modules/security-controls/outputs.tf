# ============================================================================
# AWS Security Controls Module Outputs
# ============================================================================

# ============================================================================
# S3 Account Public Access Block Outputs (SecurityHub Control S3.1)
# ============================================================================

output "s3_account_public_access_block_enabled" {
  description = "Whether S3 account public access block is enabled"
  value       = var.enable_s3_account_public_access_block
}

output "s3_account_public_access_block_id" {
  description = "The account ID for which the S3 account public access block configuration is applied"
  value       = var.enable_s3_account_public_access_block ? try(aws_s3_account_public_access_block.security_control[0].id, null) : null
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
# EBS Encryption Outputs (SecurityHub Control EC2.7)
# ============================================================================

output "ebs_encryption_by_default_enabled" {
  description = "Whether EBS encryption by default is enabled"
  value       = var.enable_ebs_encryption_by_default
}

output "ebs_encryption_by_default_id" {
  description = "The region where EBS encryption by default is configured"
  value       = var.enable_ebs_encryption_by_default ? try(aws_ebs_encryption_by_default.security_control[0].id, null) : null
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
# Security Controls Compliance Status
# ============================================================================

output "security_controls_summary" {
  description = "Summary of deployed security controls and their compliance status"
  value = {
    securityhub_controls = {
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
      module_version = "1.0.0"
    }
  }
}

# ============================================================================
# Debugging and Validation Outputs
# ============================================================================

output "module_configuration" {
  description = "Module configuration details for debugging and validation"
  value = {
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
    }
  }
}
