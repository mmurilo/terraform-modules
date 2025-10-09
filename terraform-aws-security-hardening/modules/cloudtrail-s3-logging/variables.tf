################################################################################
# General
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

variable "create_s3_bucket_policy" {
  description = "Whether to create the S3 bucket policy for CloudTrail"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

################################################################################
# Control Tower / Multi-Account Configuration
################################################################################

variable "log_archive_account_id" {
  description = "The AWS account ID of the Log Archive Account where the S3 bucket is located. If not provided, uses the current account"
  type        = string
  default     = null
}

variable "management_account_id" {
  description = "The AWS account ID of the Management Account where the CloudTrail is created. If not provided, uses the current account"
  type        = string
  default     = null
}

################################################################################
# CloudTrail
################################################################################

variable "trail_name" {
  description = "The name of the CloudTrail"
  type        = string
  default     = "S3-Object-Logs"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs. If not provided, a bucket will be created"
  type        = string
  default     = null
}

variable "s3_bucket_name_prefix" {
  description = "The prefix to use for the S3 bucket name when creating a new bucket"
  type        = string
  default     = "s3-objects"
}

variable "s3_key_prefix" {
  description = "The prefix for the location in the S3 bucket"
  type        = string
  default     = ""
}

variable "include_global_service_events" {
  description = "Whether to include events from global services such as IAM"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Whether the trail is created in the current region or in all regions"
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = "Whether the trail is an AWS Organizations trail. Organization trails log events for the master account and all member accounts. Can only be created in the organization master account"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Whether to enable logging for the trail"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Whether to enable log file integrity validation"
  type        = bool
  default     = true
}

################################################################################
# KMS Encryption Configuration
################################################################################

variable "create_kms_key" {
  description = "Whether to create a dedicated KMS key for CloudTrail log encryption. If true, creates a new key. If false, uses the provided kms_key_id or defaults to S3 managed encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The KMS key ID/ARN to use for encrypting CloudTrail logs. If not provided and create_kms_key is true, a new key will be created. If not provided and create_kms_key is false, S3 managed encryption (AES256) will be used"
  type        = string
  default     = null
}

variable "kms_key_alias" {
  description = "The alias for the KMS key. Only used when create_kms_key is true"
  type        = string
  default     = null
}

variable "kms_key_deletion_window" {
  description = "The number of days after which the KMS key will be deleted when destroyed. Must be between 7 and 30 days"
  type        = number
  default     = 30
  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "kms_key_rotation" {
  description = "Whether to enable automatic key rotation for the created KMS key"
  type        = bool
  default     = true
}

variable "sns_topic_name" {
  description = "The name of the SNS topic for CloudTrail notifications"
  type        = string
  default     = null
}

################################################################################
# S3 Bucket Configuration
################################################################################

variable "force_destroy_s3_bucket" {
  description = "Whether to force destroy the S3 bucket (allows deletion of non-empty bucket)"
  type        = bool
  default     = false
}

variable "enable_lifecycle_configuration" {
  description = "Whether to enable S3 lifecycle configuration for CloudTrail logs"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudTrail logs before deletion. If null, logs are retained indefinitely"
  type        = number
  default     = null
}

################################################################################
# CloudWatch Logs Configuration
################################################################################

variable "enable_cloudwatch_logs" {
  description = "Whether to enable CloudWatch Logs for CloudTrail"
  type        = bool
  default     = true
}

variable "cloudwatch_logs_retention_in_days" {
  description = "The number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "cloudwatch_logs_kms_key_id" {
  description = "The KMS key ID to use for encrypting CloudWatch logs. If not provided, defaults to the CloudTrail KMS key if created, otherwise uses CloudWatch default encryption"
  type        = string
  default     = null
}

################################################################################
# S3 Event Filtering Configuration
################################################################################

variable "s3_buckets_to_monitor" {
  description = "List of S3 bucket ARNs to monitor for data events. If empty, all S3 buckets will be monitored"
  type        = list(string)
  default     = []
}

variable "s3_buckets_to_exclude" {
  description = "List of S3 bucket ARNs to exclude from monitoring"
  type        = list(string)
  default     = []
}

variable "include_management_events" {
  description = "Whether to include management events in addition to S3 data events"
  type        = bool
  default     = false
}

################################################################################
# S3 Access Logging Configuration (SecurityHub CloudTrail.7)
################################################################################

variable "enable_s3_access_logging" {
  description = "Whether to enable S3 access logging on the CloudTrail S3 bucket (SecurityHub CloudTrail.7)"
  type        = bool
  default     = true
}

variable "create_access_logs_bucket" {
  description = "Whether to create a separate S3 bucket for access logs. If false, you must provide access_logs_bucket_name"
  type        = bool
  default     = true
}

variable "access_logs_bucket_name" {
  description = "The name of the S3 bucket for access logs. If not provided and create_access_logs_bucket is true, a bucket will be created"
  type        = string
  default     = null
}



variable "access_logs_target_prefix" {
  description = "The prefix for access log objects"
  type        = string
  default     = "access-logs/"
}

variable "access_logs_bucket_force_destroy" {
  description = "Whether to force destroy the access logs S3 bucket (allows deletion of non-empty bucket)"
  type        = bool
  default     = false
}

variable "access_logs_bucket_lifecycle_enabled" {
  description = "Whether to enable lifecycle configuration for access logs bucket"
  type        = bool
  default     = true
}

variable "access_logs_retention_days" {
  description = "Number of days to retain access logs before deletion. If null, logs are retained indefinitely"
  type        = number
  default     = 90
}

################################################################################
# S3 SSL Enforcement Configuration (SecurityHub S3.5)
################################################################################

variable "enforce_ssl" {
  description = "Whether to enforce SSL/HTTPS for all requests to the CloudTrail S3 bucket (SecurityHub S3.5)"
  type        = bool
  default     = true
}

variable "access_logs_enforce_ssl" {
  description = "Whether to enforce SSL/HTTPS for all requests to the access logs S3 bucket (SecurityHub S3.5)"
  type        = bool
  default     = true
}
