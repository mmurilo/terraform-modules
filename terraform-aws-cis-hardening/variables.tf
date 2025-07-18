# ============================================================================
# AWS CIS Hardening Terraform Module Variables
# 
# This file exposes all variables from the submodules:
# - IAM Access Analyzer  
# - IAM Password Policy
# - Security Controls
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
# Module Control Variables
# ============================================================================

variable "create_iam_access_analyzer" {
  description = "Whether to create IAM Access Analyzer resources"
  type        = bool
  default     = true
}

variable "create_iam_password_policy" {
  description = "Whether to create IAM Password Policy resources"
  type        = bool
  default     = true
}

variable "create_security_controls" {
  description = "Whether to create Security Controls resources"
  type        = bool
  default     = true
}

# ============================================================================
# IAM Access Analyzer Module Variables
# ============================================================================

variable "iam_access_analyzer_name" {
  description = "Name of the analyzer. If not provided, a default name will be used based on analyzer type"
  type        = string
  default     = null
}

variable "iam_access_analyzer_type" {
  description = "Type of analyzer. Valid values are ACCOUNT, ORGANIZATION, ORGANIZATION_UNUSED_ACCESS"
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
  })
  default = null
}

variable "iam_access_analyzer_archive_rules" {
  description = "Map of archive rules to create for the analyzer"
  type = map(object({
    filters = list(object({
      criteria = string
      contains = optional(list(string))
      eq       = optional(list(string))
      exists   = optional(string)
      neq      = optional(list(string))
    }))
  }))
  default = {}
}

# ============================================================================
# IAM Password Policy Module Variables
# ============================================================================

variable "iam_password_policy_minimum_password_length" {
  description = "Minimum length to require for IAM user passwords"
  type        = number
  default     = 14
  validation {
    condition     = var.iam_password_policy_minimum_password_length >= 6 && var.iam_password_policy_minimum_password_length <= 128
    error_message = "Password length must be between 6 and 128 characters."
  }
}

variable "iam_password_policy_require_lowercase_characters" {
  description = "Whether to require lowercase characters for IAM user passwords"
  type        = bool
  default     = true
}

variable "iam_password_policy_require_uppercase_characters" {
  description = "Whether to require uppercase characters for IAM user passwords"
  type        = bool
  default     = true
}

variable "iam_password_policy_require_numbers" {
  description = "Whether to require numbers for IAM user passwords"
  type        = bool
  default     = true
}

variable "iam_password_policy_require_symbols" {
  description = "Whether to require symbols for IAM user passwords"
  type        = bool
  default     = true
}

variable "iam_password_policy_allow_users_to_change_password" {
  description = "Whether to allow users to change their own password"
  type        = bool
  default     = true
}

variable "iam_password_policy_hard_expiry" {
  description = "Whether users are prevented from setting a new password after their password has expired"
  type        = bool
  default     = false
}

variable "iam_password_policy_max_password_age" {
  description = "The number of days that an IAM user password is valid"
  type        = number
  default     = 90
  validation {
    condition     = var.iam_password_policy_max_password_age >= 1 && var.iam_password_policy_max_password_age <= 1095
    error_message = "Password age must be between 1 and 1095 days."
  }
}

variable "iam_password_policy_password_reuse_prevention" {
  description = "The number of previous passwords that users are prevented from reusing"
  type        = number
  default     = 24
  validation {
    condition     = var.iam_password_policy_password_reuse_prevention >= 1 && var.iam_password_policy_password_reuse_prevention <= 24
    error_message = "Password reuse prevention must be between 1 and 24."
  }
}

# ============================================================================
# Security Controls Module Variables
# ============================================================================

# S3 Account Public Access Block (SecurityHub S3.1)
variable "security_controls_enable_s3_account_public_access_block" {
  description = "Whether to enable S3 account public access block configuration"
  type        = bool
  default     = true
}

variable "security_controls_s3_block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for buckets in this account"
  type        = bool
  default     = true
}

variable "security_controls_s3_block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for buckets in this account"
  type        = bool
  default     = true
}

variable "security_controls_s3_ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for buckets in this account"
  type        = bool
  default     = true
}

variable "security_controls_s3_restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for buckets in this account"
  type        = bool
  default     = true
}

# EBS Encryption (SecurityHub EC2.7)
variable "security_controls_enable_ebs_encryption_by_default" {
  description = "Whether to enable EBS encryption by default"
  type        = bool
  default     = true
}

variable "security_controls_ebs_encryption_enabled" {
  description = "Whether or not default EBS encryption is enabled"
  type        = bool
  default     = true
}

variable "security_controls_ebs_kms_key_arn" {
  description = "The ARN of the AWS KMS key to use for EBS encryption"
  type        = string
  default     = null
}

variable "security_controls_create_ebs_kms_key" {
  description = "Whether to create a dedicated KMS key for EBS encryption"
  type        = bool
  default     = false
}

variable "security_controls_ebs_kms_key_deletion_window" {
  description = "Duration in days after which the key is deleted after destruction of the resource"
  type        = number
  default     = 7
  validation {
    condition     = var.security_controls_ebs_kms_key_deletion_window >= 7 && var.security_controls_ebs_kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "security_controls_ebs_kms_key_rotation" {
  description = "Whether to enable automatic rotation of the KMS key"
  type        = bool
  default     = true
}

variable "security_controls_ebs_kms_key_alias" {
  description = "The alias name for the EBS KMS key (must start with 'alias/')"
  type        = string
  default     = "alias/cis-hardening-ebs-encryption"
  validation {
    condition     = can(regex("^alias/", var.security_controls_ebs_kms_key_alias))
    error_message = "KMS key alias must start with 'alias/'."
  }
}

# ============================================================================
# IAM Password Policy Variables (SecurityHub IAM.7, IAM.11-17)
# ============================================================================

variable "iam_password_policy_create" {
  description = "Whether to create the IAM password policy"
  type        = bool
  default     = true
}

# ============================================================================
# AWS Support Role Variables (SecurityHub Control IAM.18)
# ============================================================================

variable "iam_password_policy_create_aws_support_role" {
  description = "Whether to create an AWS Support role for incident management (SecurityHub IAM.18)"
  type        = bool
  default     = true
}

variable "iam_password_policy_aws_support_role_name" {
  description = "The name of the AWS Support role"
  type        = string
  default     = "AWSSupport-IncidentManagement"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9+=,.@_-]{0,63}$", var.iam_password_policy_aws_support_role_name))
    error_message = "Role name must be 1-64 characters, start with a letter, and contain only alphanumeric characters and +=,.@_-"
  }
}

variable "iam_password_policy_aws_support_role_path" {
  description = "The path for the AWS Support role"
  type        = string
  default     = "/"
  validation {
    condition     = can(regex("^/([a-zA-Z0-9+=,.@_-]+/)*$", var.iam_password_policy_aws_support_role_path))
    error_message = "Path must be a valid IAM path, starting and ending with '/', for example: / or /my-path/"
  }
}

variable "iam_password_policy_aws_support_role_max_session_duration" {
  description = "Maximum session duration (in seconds) for the AWS Support role"
  type        = number
  default     = 3600
  validation {
    condition     = var.iam_password_policy_aws_support_role_max_session_duration >= 3600 && var.iam_password_policy_aws_support_role_max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 (1 hour) and 43200 (12 hours) seconds."
  }
}

variable "iam_password_policy_aws_support_role_trusted_entities" {
  description = "List of AWS account ARNs or IAM user/role ARNs that can assume the AWS Support role"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for entity in var.iam_password_policy_aws_support_role_trusted_entities : can(regex("^arn:aws(-cn|-us-gov)?:iam::[0-9]{12}:(root|user/[a-zA-Z0-9+=,.@_/-]+|role/[a-zA-Z0-9+=,.@_/-]+)$", entity))
    ])
    error_message = "Trusted entities must be valid AWS ARNs for accounts (root), users, or roles."
  }
}

variable "iam_password_policy_aws_support_role_require_mfa" {
  description = "Whether to require MFA for assuming the AWS Support role"
  type        = bool
  default     = true
}

variable "iam_password_policy_aws_support_role_tags" {
  description = "A map of tags to apply to the AWS Support role (in addition to common tags)"
  type        = map(string)
  default     = {}
}
