# ============================================================================
# AWS Security Baseline Module Variables
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
# IAM PASSWORD POLICY Variables (SecurityHub Controls IAM.7, IAM.11-17)
# ============================================================================

variable "enable_iam_password_policy" {
  description = "Whether to create the IAM password policy"
  type        = bool
  default     = true
}

variable "minimum_password_length" {
  description = "Minimum length to require for IAM user passwords"
  type        = number
  default     = 14
  validation {
    condition     = var.minimum_password_length >= 6 && var.minimum_password_length <= 128
    error_message = "Password length must be between 6 and 128 characters."
  }
}

variable "require_lowercase_characters" {
  description = "Whether to require lowercase characters for IAM user passwords"
  type        = bool
  default     = true
}

variable "require_numbers" {
  description = "Whether to require numbers for IAM user passwords"
  type        = bool
  default     = true
}

variable "require_uppercase_characters" {
  description = "Whether to require uppercase characters for IAM user passwords"
  type        = bool
  default     = true
}

variable "require_symbols" {
  description = "Whether to require symbols for IAM user passwords"
  type        = bool
  default     = true
}

variable "allow_users_to_change_password" {
  description = "Whether to allow users to change their own password"
  type        = bool
  default     = true
}

variable "hard_expiry" {
  description = "Whether users are prevented from setting a new password after their password has expired (i.e., hard expiry)"
  type        = bool
  default     = false
}

variable "max_password_age" {
  description = "The number of days that an IAM user password is valid"
  type        = number
  default     = 90
  validation {
    condition     = var.max_password_age >= 1 && var.max_password_age <= 1095
    error_message = "Password age must be between 1 and 1095 days."
  }
}

variable "password_reuse_prevention" {
  description = "The number of previous passwords that users are prevented from reusing"
  type        = number
  default     = 24
  validation {
    condition     = var.password_reuse_prevention >= 1 && var.password_reuse_prevention <= 24
    error_message = "Password reuse prevention must be between 1 and 24."
  }
}

# ============================================================================
# AWS SUPPORT ROLE Variables (SecurityHub Control IAM.18)
# ============================================================================

variable "enable_aws_support_role" {
  description = "Whether to create an AWS Support role for incident management (SecurityHub IAM.18)"
  type        = bool
  default     = true
}

variable "aws_support_role_name" {
  description = "The name of the AWS Support role"
  type        = string
  default     = "AWSSupport-IncidentManagement"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9+=,.@_-]{0,63}$", var.aws_support_role_name))
    error_message = "Role name must be 1-64 characters, start with a letter, and contain only alphanumeric characters and +=,.@_-"
  }
}

variable "aws_support_role_path" {
  description = "The path for the AWS Support role"
  type        = string
  default     = "/"
  validation {
    condition     = can(regex("^/([a-zA-Z0-9+=,.@_-]+/)*$", var.aws_support_role_path))
    error_message = "Path must be a valid IAM path, starting and ending with '/', for example: / or /my-path/"
  }
}

variable "aws_support_role_max_session_duration" {
  description = "Maximum session duration (in seconds) for the AWS Support role"
  type        = number
  default     = 3600
  validation {
    condition     = var.aws_support_role_max_session_duration >= 3600 && var.aws_support_role_max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 (1 hour) and 43200 (12 hours) seconds."
  }
}

variable "aws_support_role_trusted_entities" {
  description = "List of AWS account ARNs or IAM user/role ARNs that can assume the AWS Support role. If empty, defaults to current account root for security and IAM.18 compliance"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for entity in var.aws_support_role_trusted_entities : can(regex("^arn:aws(-cn|-us-gov)?:iam::[0-9]{12}:(root|user/[a-zA-Z0-9+=,.@_/-]+|role/[a-zA-Z0-9+=,.@_/-]+)$", entity))
    ])
    error_message = "Trusted entities must be valid AWS ARNs for accounts (root), users, or roles."
  }
}

variable "aws_support_role_require_mfa" {
  description = "Whether to require MFA for assuming the AWS Support role"
  type        = bool
  default     = true
}

variable "aws_support_role_tags" {
  description = "A map of tags to apply to the AWS Support role"
  type        = map(string)
  default = {
    Name        = "AWS Support Role"
    SecurityHub = "IAM.18"
    Purpose     = "AWS Support incident management"
    ManagedBy   = "terraform"
  }
}

# ============================================================================
# IAM ACCESS ANALYZER Variables (SecurityHub Control IAM.28)
# ============================================================================

variable "enable_iam_access_analyzer" {
  description = "Whether to create an IAM Access Analyzer external access analyzer (SecurityHub IAM.28)"
  type        = bool
  default     = true
}

variable "iam_access_analyzer_name" {
  description = "The name of the IAM Access Analyzer"
  type        = string
  default     = "security-baseline-external-analyzer"
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9\\-_.]{0,254}$", var.iam_access_analyzer_name))
    error_message = "Analyzer name must be 1-255 characters, start with alphanumeric, and contain only alphanumeric characters, hyphens, underscores, and periods."
  }
}

variable "iam_access_analyzer_type" {
  description = <<-EOT
    Type of IAM Access Analyzer:
    - ACCOUNT: External access analyzer for account (IAM.28 compliant)
    - ORGANIZATION: External access analyzer for organization (IAM.28 compliant)  
    - ORGANIZATION_UNUSED_ACCESS: Unused access analyzer (NOT IAM.28 compliant)
    
    Note: For SecurityHub IAM.28 compliance, use ACCOUNT or ORGANIZATION only.
  EOT
  type        = string
  default     = "ACCOUNT"
  validation {
    condition = contains([
      "ACCOUNT",
      "ORGANIZATION",
      "ORGANIZATION_UNUSED_ACCESS"
    ], var.iam_access_analyzer_type)
    error_message = "Analyzer type must be one of: ACCOUNT, ORGANIZATION, ORGANIZATION_UNUSED_ACCESS."
  }
}

variable "iam_access_analyzer_unused_access_configuration" {
  description = "Configuration for unused access analyzer. Only applicable when type is ORGANIZATION_UNUSED_ACCESS"
  type = object({
    unused_access_age = number
    analysis_rule = optional(object({
      exclusion = optional(list(object({
        account_ids   = optional(list(string))
        resource_tags = optional(list(map(string)))
      })))
    }))
  })
  default = null
}

variable "iam_access_analyzer_archive_rules" {
  description = "Map of archive rules to create for the IAM Access Analyzer"
  type = map(object({
    filters = list(object({
      criteria = string
      contains = optional(list(string))
      eq       = optional(list(string))
      exists   = optional(bool)
      neq      = optional(list(string))
    }))
  }))
  default = {}
}

variable "iam_access_analyzer_tags" {
  description = "A map of tags to apply to the IAM Access Analyzer"
  type        = map(string)
  default = {
    Name        = "Security Baseline External Access Analyzer"
    SecurityHub = "IAM.28"
    Purpose     = "External access analysis for unintended resource sharing"
    ManagedBy   = "terraform"
  }
}

# ============================================================================
# S3 ACCOUNT PUBLIC ACCESS BLOCK Variables (SecurityHub Control S3.1)
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
# EBS ENCRYPTION Variables (SecurityHub Control EC2.7)
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
  validation {
    condition     = var.ebs_kms_key_arn == null ? true : can(regex("^arn:aws(-cn|-us-gov)?:kms:[a-z0-9-]+:[0-9]{12}:key/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.ebs_kms_key_arn))
    error_message = "EBS KMS key ARN must be a valid KMS key ARN or null."
  }
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
  default     = "alias/security-baseline-ebs-encryption"
  validation {
    condition     = can(regex("^alias/", var.ebs_kms_key_alias))
    error_message = "KMS key alias must start with 'alias/'."
  }
}
