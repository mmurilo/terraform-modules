# Control Tower CloudTrail S3 Logging Example Outputs

################################################################################
# CloudTrail Outputs
################################################################################

output "cloudtrail_arn" {
  description = "ARN of the created CloudTrail"
  value       = module.cloudtrail_s3_logging.cloudtrail_arn
}

output "cloudtrail_name" {
  description = "Name of the created CloudTrail"
  value       = module.cloudtrail_s3_logging.cloudtrail_name
}

################################################################################
# KMS Encryption Outputs
################################################################################

output "kms_key_id" {
  description = "ID of the KMS key used for CloudTrail log encryption"
  value       = module.cloudtrail_s3_logging.kms_key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for CloudTrail log encryption"
  value       = module.cloudtrail_s3_logging.kms_key_arn
}

output "kms_key_alias" {
  description = "Alias of the KMS key used for CloudTrail log encryption"
  value       = module.cloudtrail_s3_logging.kms_key_alias
}

output "kms_key_created" {
  description = "Whether a new KMS key was created by this module"
  value       = module.cloudtrail_s3_logging.kms_key_created
}

output "sso_admin_role_arns" {
  description = "List of SSO Administrator role ARNs granted decrypt permissions on the KMS key"
  value       = module.cloudtrail_s3_logging.sso_admin_role_arns
}

output "sso_admin_roles_found" {
  description = "Number of SSO Administrator roles found in the Log Archive Account"
  value       = module.cloudtrail_s3_logging.sso_admin_roles_found
}

################################################################################
# S3 Bucket Outputs
################################################################################

output "s3_bucket_name" {
  description = "Name of the S3 bucket storing CloudTrail logs"
  value       = module.cloudtrail_s3_logging.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket storing CloudTrail logs"
  value       = module.cloudtrail_s3_logging.s3_bucket_arn
}

output "s3_bucket_kms_encrypted" {
  description = "Whether the S3 bucket is encrypted with KMS"
  value       = module.cloudtrail_s3_logging.s3_bucket_kms_encrypted
}

################################################################################
# Account Configuration Outputs
################################################################################

output "log_archive_account_id" {
  description = "AWS account ID where the S3 bucket is located"
  value       = module.cloudtrail_s3_logging.log_archive_account_id
}

output "management_account_id" {
  description = "AWS account ID where the CloudTrail is created"
  value       = module.cloudtrail_s3_logging.management_account_id
}

output "is_cross_account_setup" {
  description = "Whether this is a cross-account setup"
  value       = module.cloudtrail_s3_logging.is_cross_account_setup
}

################################################################################
# CloudWatch Logs Outputs
################################################################################

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group (if enabled)"
  value       = module.cloudtrail_s3_logging.cloudwatch_log_group_name
}

output "cloudwatch_logs_kms_encrypted" {
  description = "Whether CloudWatch logs are encrypted with KMS"
  value       = module.cloudtrail_s3_logging.cloudwatch_logs_kms_encrypted
}
