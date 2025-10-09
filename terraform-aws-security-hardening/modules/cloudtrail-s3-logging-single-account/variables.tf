# CloudTrail S3 Logging Module Variables

################################################################################
# General Configuration
################################################################################

variable "create_cloudtrail" {
  description = "Whether to create the CloudTrail"
  type        = bool
  default     = true
}

variable "create_s3_bucket" {
  description = "Whether to create the S3 bucket for CloudTrail logs"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

################################################################################
# CloudTrail Configuration
################################################################################

variable "trail_name" {
  description = "Name of the CloudTrail"
  type        = string
  default     = "org-s3-data-events"
}

variable "s3_bucket_name" {
  description = "Name of existing S3 bucket for CloudTrail logs (if not creating new bucket)"
  type        = string
  default     = null
}

variable "s3_bucket_name_prefix" {
  description = "Prefix for S3 bucket name (will be suffixed with account ID and random string)"
  type        = string
  default     = "org-cloudtrail"
}

variable "s3_key_prefix" {
  description = "S3 key prefix for CloudTrail log files"
  type        = string
  default     = "s3-events/"
}

variable "include_global_service_events" {
  description = "Whether to include events from global services"
  type        = bool
  default     = false
}

variable "is_multi_region_trail" {
  description = "Whether the trail is a multi-region trail"
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Whether the trail is an organization trail"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Whether to enable logging for the trail"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Whether to enable log file validation"
  type        = bool
  default     = true
}

################################################################################
# KMS Configuration
################################################################################

variable "create_kms_key" {
  description = "Whether to create a KMS key for CloudTrail encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for CloudTrail encryption (if not creating new key)"
  type        = string
  default     = null
}

variable "kms_key_alias" {
  description = "Alias for the KMS key"
  type        = string
  default     = "cloudtrail-s3-logging"
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
}

variable "kms_key_rotation" {
  description = "Whether to enable KMS key rotation"
  type        = bool
  default     = true
}

################################################################################
# S3 Bucket Configuration
################################################################################

variable "force_destroy_s3_bucket" {
  description = "Whether to force destroy the S3 bucket (delete all objects)"
  type        = bool
  default     = false
}

variable "enable_lifecycle_configuration" {
  description = "Whether to enable S3 lifecycle configuration"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs (0 = indefinitely)"
  type        = number
  default     = 2555 # 7 years
}

variable "enforce_ssl" {
  description = "Whether to enforce SSL/HTTPS for S3 bucket access (SecurityHub S3.5)"
  type        = bool
  default     = true
}

################################################################################
# S3 Access Logging Configuration (SecurityHub CloudTrail.7)
################################################################################

variable "enable_s3_access_logging" {
  description = "Whether to enable S3 access logging on the CloudTrail bucket"
  type        = bool
  default     = true
}

variable "create_access_logs_bucket" {
  description = "Whether to create a separate bucket for S3 access logs"
  type        = bool
  default     = true
}

variable "access_logs_bucket_name" {
  description = "Name of existing S3 bucket for access logs (if not creating new bucket)"
  type        = string
  default     = null
}

variable "access_logs_target_prefix" {
  description = "S3 key prefix for access logs"
  type        = string
  default     = "access-logs/"
}

variable "access_logs_bucket_force_destroy" {
  description = "Whether to force destroy the access logs S3 bucket"
  type        = bool
  default     = false
}

variable "access_logs_retention_days" {
  description = "Number of days to retain access logs (0 = indefinitely)"
  type        = number
  default     = 90
}

################################################################################
# S3 Data Events Configuration
################################################################################

variable "s3_buckets_to_monitor" {
  description = "List of S3 bucket ARNs to monitor for data events. Empty list monitors all buckets"
  type        = list(string)
  default     = []
}
