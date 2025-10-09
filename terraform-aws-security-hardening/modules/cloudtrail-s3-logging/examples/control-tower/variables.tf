# Control Tower CloudTrail S3 Logging Example Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "log_archive_account_id" {
  description = "AWS account ID of the Log Archive Account"
  type        = string
  # No default - must be provided
}

variable "cross_account_role_name" {
  description = "Name of the cross-account role in the Log Archive Account"
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "trail_name" {
  description = "Name of the CloudTrail"
  type        = string
  default     = "control-tower-s3-data-events"
}

variable "s3_bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "ct-cloudtrail-s3-logs"
}

################################################################################
# KMS Encryption Configuration
################################################################################

variable "create_kms_key" {
  description = "Whether to create a dedicated KMS key for CloudTrail log encryption"
  type        = bool
  default     = true
}

variable "kms_key_alias" {
  description = "The alias for the KMS key used for CloudTrail encryption"
  type        = string
  default     = "control-tower-cloudtrail-encryption"
}

variable "kms_key_rotation" {
  description = "Whether to enable automatic key rotation for the KMS key"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window" {
  description = "Number of days for KMS key deletion window (7-30 days)"
  type        = number
  default     = 30
  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

################################################################################
# Lifecycle and Retention Configuration
################################################################################

variable "log_retention_days" {
  description = "Number of days to retain CloudTrail logs (null for indefinite retention)"
  type        = number
  default     = 2555 # ~7 years
}

variable "enable_cloudwatch_logs" {
  description = "Whether to enable CloudWatch Logs for real-time monitoring"
  type        = bool
  default     = false
}

variable "cloudwatch_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 90
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
  default     = "control-tower"
}
