variable "enable_stacksets" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Access Analyzer
variable "create_access_analyzer" {
  type    = bool
  default = true
}
variable "access_analyzer_type" {
  type    = string
  default = "ORGANIZATION"
}
variable "access_analyzer_name" {
  type    = string
  default = "org-external-access"
}

# Centralized Root Access Management
variable "enable_centralized_root_access" {
  description = "Whether to enable centralized root access management for organization member accounts (IAM.6 compliance)"
  type        = bool
  default     = true
}

variable "centralized_root_access_features" {
  description = "List of centralized root access features to enable. Valid values: RootCredentialsManagement, RootSessions"
  type        = list(string)
  default     = ["RootCredentialsManagement", "RootSessions"]

  validation {
    condition = alltrue([
      for feature in var.centralized_root_access_features :
      contains(["RootCredentialsManagement", "RootSessions"], feature)
    ])
    error_message = "Valid values are 'RootCredentialsManagement' and 'RootSessions'."
  }
}


# Unused Access Configuration
variable "access_analyzer_unused_access_configuration" {
  description = "Configuration for unused access analyzer"
  type = object({
    unused_access_age = number
  })
  default = null
}

# Archive Rules Configuration
variable "access_analyzer_archive_rules" {
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

################################################################################
# IAM Access Analyzer (Per-Account via StackSets)
################################################################################

variable "create_iam_access_analyzer" {
  description = "Whether to create IAM Access Analyzer in each account via StackSets"
  type        = bool
  default     = true
}

variable "iam_access_analyzer_name" {
  description = "Name of the IAM Access Analyzer to create per account"
  type        = string
  default     = "security-baseline-external-analyzer"
}

variable "iam_access_analyzer_type" {
  description = "Type of IAM Access Analyzer (ACCOUNT, ORGANIZATION, ORGANIZATION_UNUSED_ACCESS)"
  type        = string
  default     = "ACCOUNT"
  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION", "ORGANIZATION_UNUSED_ACCESS"], var.iam_access_analyzer_type)
    error_message = "Valid values are 'ACCOUNT', 'ORGANIZATION', or 'ORGANIZATION_UNUSED_ACCESS'."
  }
}

variable "iam_access_analyzer_unused_access_age" {
  description = "Number of days to consider access as unused (only for ORGANIZATION_UNUSED_ACCESS type)"
  type        = number
  default     = 90
}

variable "create_iam_access_analyzer_archive_rules" {
  description = "Whether to create default archive rules for the IAM Access Analyzer"
  type        = bool
  default     = false
}

variable "iam_access_analyzer_s3_bucket_exclusion" {
  description = "S3 bucket name to exclude from IAM Access Analyzer findings (creates archive rule if provided)"
  type        = string
  default     = ""
}

# StackSets
variable "stackset_name" {
  type    = string
  default = "org-baseline-security"
}
variable "stacksets_organizational_unit_ids" {
  type    = list(string)
  default = []
}
variable "stacksets_regions" {
  type    = list(string)
  default = ["us-east-1"]
}

# Per-account baseline parameters
variable "s3_pab_block_public_acls" {
  type    = bool
  default = true
}
variable "s3_pab_block_public_policy" {
  type    = bool
  default = true
}
variable "s3_pab_ignore_public_acls" {
  type    = bool
  default = true
}
variable "s3_pab_restrict_public_buckets" {
  type    = bool
  default = true
}

variable "ebs_encryption_by_default" {
  type    = bool
  default = true
}
variable "ebs_default_kms_key_id" {
  description = "ARN of existing KMS key to use for EBS encryption (alternative to creating new key)"
  type        = string
  default     = null
}

# NEW KMS Key Creation Variables
variable "create_ebs_kms_key" {
  description = "Whether to create a dedicated KMS key for EBS encryption"
  type        = bool
  default     = false
}

variable "ebs_kms_key_alias" {
  description = "Alias for the EBS encryption KMS key (must start with 'alias/')"
  type        = string
  default     = "alias/security-baseline-ebs-encryption"

  validation {
    condition     = can(regex("^alias/", var.ebs_kms_key_alias))
    error_message = "KMS key alias must start with 'alias/'."
  }
}

variable "ebs_kms_key_rotation" {
  description = "Enable automatic rotation for the EBS encryption KMS key"
  type        = bool
  default     = true
}

variable "ebs_kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7

  validation {
    condition     = var.ebs_kms_key_deletion_window >= 7 && var.ebs_kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "create_password_policy" {
  type    = bool
  default = true
}
variable "password_min_length" {
  type    = number
  default = 14
}
variable "password_require_symbols" {
  type    = bool
  default = true
}
variable "password_require_numbers" {
  type    = bool
  default = true
}
variable "password_require_uppercase" {
  type    = bool
  default = true
}
variable "password_require_lowercase" {
  type    = bool
  default = true
}
variable "password_allow_users_to_change" {
  type    = bool
  default = true
}
variable "password_max_age" {
  type    = number
  default = 90
}
variable "password_reuse_prevention" {
  type    = number
  default = 24
}
variable "password_hard_expiry" {
  type    = bool
  default = false
}

################################################################################
# AWS Support Role Configuration (deployed via StackSets)
################################################################################

variable "create_aws_support_role" {
  description = "Whether to create AWS Support role for incident management (per-account)"
  type        = bool
  default     = true
}

variable "aws_support_role_name" {
  description = "Name of the AWS Support role"
  type        = string
  default     = "AWSSupport-IncidentManagement"
}

variable "aws_support_role_require_mfa" {
  description = "Whether to require MFA for assuming the AWS Support role"
  type        = bool
  default     = true
}

variable "aws_support_role_max_session_duration" {
  description = "Maximum session duration for the AWS Support role in seconds"
  type        = number
  default     = 3600
}

variable "aws_support_trusted_entities_mode" {
  description = "Select who can assume the Support role (root=current account root, custom=provide ARNs)"
  type        = string
  default     = "root"
  validation {
    condition     = contains(["root", "custom"], var.aws_support_trusted_entities_mode)
    error_message = "Valid values for aws_support_trusted_entities_mode are 'root' or 'custom'."
  }
}

variable "aws_support_trusted_entities" {
  description = "Comma-separated list of trusted entity ARNs allowed to assume the Support role (used when mode is custom)"
  type        = string
  default     = ""
}

################################################################################
# CloudTrail S3 Logging Configuration (Management Account)
################################################################################

variable "enable_cloudtrail" {
  description = "Whether to enable CloudTrail S3 logging for SecurityHub compliance"
  type        = bool
  default     = true
}

variable "log_archive_account_id" {
  description = "The AWS account ID of the Log Archive Account where the S3 bucket is located. If not provided, uses the current account"
  type        = string
  default     = null
}


variable "cloudtrail_name" {
  description = "Name of the CloudTrail"
  type        = string
  default     = "org-s3-data-events"
}

variable "cloudtrail_s3_bucket_name_prefix" {
  description = "Prefix for CloudTrail S3 bucket name"
  type        = string
  default     = "org-cloudtrail"
}

variable "cloudtrail_is_organization_trail" {
  description = "Whether the CloudTrail is an organization trail"
  type        = bool
  default     = true
}

variable "cloudtrail_enable_s3_access_logging" {
  description = "Whether to enable S3 access logging for SecurityHub CloudTrail.7 compliance"
  type        = bool
  default     = true
}

variable "cloudtrail_enforce_ssl" {
  description = "Whether to enforce SSL/HTTPS for CloudTrail S3 bucket (SecurityHub S3.5)"
  type        = bool
  default     = true
}

variable "cloudtrail_s3_buckets_to_monitor" {
  description = "List of S3 bucket ARNs to monitor for data events. Empty list monitors all buckets"
  type        = list(string)
  default     = []
}

variable "cloudtrail_log_retention_days" {
  description = "Number of days to retain CloudTrail logs (0 = indefinitely)"
  type        = number
  default     = 2555 # 7 years
}


