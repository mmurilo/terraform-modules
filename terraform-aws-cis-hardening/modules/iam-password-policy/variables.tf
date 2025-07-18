variable "create" {
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
# AWS Support Role Variables (SecurityHub Control IAM.18)
# ============================================================================

variable "create_aws_support_role" {
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
