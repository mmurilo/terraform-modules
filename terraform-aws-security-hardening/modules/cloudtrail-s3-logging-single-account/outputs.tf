# CloudTrail S3 Logging Module Outputs

################################################################################
# CloudTrail Outputs
################################################################################

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = try(aws_cloudtrail.this[0].id, null)
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = try(aws_cloudtrail.this[0].arn, null)
}

output "cloudtrail_name" {
  description = "CloudTrail name"
  value       = try(aws_cloudtrail.this[0].name, null)
}

################################################################################
# S3 Bucket Outputs
################################################################################

output "s3_bucket_id" {
  description = "CloudTrail S3 bucket ID"
  value       = try(aws_s3_bucket.cloudtrail[0].id, null)
}

output "s3_bucket_arn" {
  description = "CloudTrail S3 bucket ARN"
  value       = try(aws_s3_bucket.cloudtrail[0].arn, null)
}

output "s3_bucket_name" {
  description = "CloudTrail S3 bucket name"
  value       = try(aws_s3_bucket.cloudtrail[0].id, var.s3_bucket_name)
}

output "s3_bucket_domain_name" {
  description = "CloudTrail S3 bucket domain name"
  value       = try(aws_s3_bucket.cloudtrail[0].bucket_domain_name, null)
}

output "s3_bucket_region" {
  description = "CloudTrail S3 bucket region"
  value       = try(aws_s3_bucket.cloudtrail[0].region, null)
}

################################################################################
# KMS Key Outputs
################################################################################

output "kms_key_id" {
  description = "KMS key ID used for encryption"
  value       = var.create_kms_key ? try(aws_kms_key.cloudtrail[0].key_id, null) : var.kms_key_id
}

output "kms_key_arn" {
  description = "KMS key ARN used for encryption"
  value       = var.create_kms_key ? try(aws_kms_key.cloudtrail[0].arn, null) : var.kms_key_id
}

output "kms_key_alias" {
  description = "KMS key alias"
  value       = try(aws_kms_alias.cloudtrail[0].name, null)
}

################################################################################
# S3 Access Logging Outputs (SecurityHub CloudTrail.7)
################################################################################

output "access_logs_bucket_id" {
  description = "S3 access logs bucket ID"
  value       = try(aws_s3_bucket.access_logs[0].id, null)
}

output "access_logs_bucket_name" {
  description = "S3 access logs bucket name"
  value       = try(aws_s3_bucket.access_logs[0].id, var.access_logs_bucket_name)
}

output "access_logs_bucket_arn" {
  description = "S3 access logs bucket ARN"
  value       = try(aws_s3_bucket.access_logs[0].arn, null)
}

output "s3_access_logging_enabled" {
  description = "Whether S3 access logging is enabled on the CloudTrail bucket"
  value       = var.enable_s3_access_logging && (local.create_access_logs_bucket || var.access_logs_bucket_name != null)
}

################################################################################
# Security Compliance Outputs
################################################################################

output "securityhub_compliance" {
  description = "SecurityHub compliance status for controls addressed by this module"
  value = {
    s3_22_object_write_events = var.create_cloudtrail        # S3 buckets should log object-level write events
    s3_23_object_read_events  = var.create_cloudtrail        # S3 buckets should log object-level read events
    cloudtrail_7_s3_logging   = var.enable_s3_access_logging # CloudTrail S3 bucket should have access logging configured
    s3_5_ssl_enforcement      = var.enforce_ssl              # S3 buckets should require requests to use SSL/HTTPS
  }
}

output "s3_ssl_enforcement_enabled" {
  description = "Whether SSL/HTTPS enforcement is enabled for the S3 bucket"
  value       = var.enforce_ssl
}
