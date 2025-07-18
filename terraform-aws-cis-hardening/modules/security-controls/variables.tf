# ============================================================================
# AWS Security Controls Module Variables
# ============================================================================

# ============================================================================
# General Variables
# ============================================================================

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# S3 Account Public Access Block Variables (SecurityHub Control S3.1)
# ============================================================================

variable "enable_s3_account_public_access_block" {
  description = "Whether to enable S3 account public access block configuration"
  type        = bool
  default     = true
}

variable "s3_block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for buckets in this account"
  type        = bool
  default     = true
}

variable "s3_block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for buckets in this account"
  type        = bool
  default     = true
}

variable "s3_ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for buckets in this account"
  type        = bool
  default     = true
}

variable "s3_restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for buckets in this account"
  type        = bool
  default     = true
}

# ============================================================================
# EBS Encryption Variables (SecurityHub Control EC2.7)
# ============================================================================

variable "enable_ebs_encryption_by_default" {
  description = "Whether to enable EBS encryption by default"
  type        = bool
  default     = true
}

variable "ebs_encryption_enabled" {
  description = "Whether or not default EBS encryption is enabled"
  type        = bool
  default     = true
}

variable "ebs_kms_key_arn" {
  description = "The ARN of the AWS KMS key to use for EBS encryption (optional - uses AWS managed key if not specified)"
  type        = string
  default     = null
}

variable "create_ebs_kms_key" {
  description = "Whether to create a dedicated KMS key for EBS encryption"
  type        = bool
  default     = false
}

variable "ebs_kms_key_deletion_window" {
  description = "Duration in days after which the key is deleted after destruction of the resource"
  type        = number
  default     = 7
  validation {
    condition     = var.ebs_kms_key_deletion_window >= 7 && var.ebs_kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "ebs_kms_key_rotation" {
  description = "Whether to enable automatic rotation of the KMS key"
  type        = bool
  default     = true
}

variable "ebs_kms_key_alias" {
  description = "The alias name for the EBS KMS key (must start with 'alias/')"
  type        = string
  default     = "alias/security-controls-ebs-encryption"
  validation {
    condition     = can(regex("^alias/", var.ebs_kms_key_alias))
    error_message = "KMS key alias must start with 'alias/'."
  }
}
