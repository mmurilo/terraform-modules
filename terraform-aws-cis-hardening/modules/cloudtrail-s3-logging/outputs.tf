################################################################################
# CloudTrail
################################################################################

output "cloudtrail_id" {
  description = "The ID of the CloudTrail"
  value       = try(aws_cloudtrail.this[0].id, null)
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail"
  value       = try(aws_cloudtrail.this[0].arn, null)
}

output "cloudtrail_name" {
  description = "The name of the CloudTrail"
  value       = try(aws_cloudtrail.this[0].name, null)
}

output "cloudtrail_home_region" {
  description = "The home region of the CloudTrail"
  value       = try(aws_cloudtrail.this[0].home_region, null)
}

################################################################################
# Account Configuration
################################################################################

output "current_account_id" {
  description = "The current AWS account ID where the module is deployed"
  value       = data.aws_caller_identity.current.account_id
}

output "log_archive_account_id" {
  description = "The AWS account ID where the S3 bucket is located (Log Archive Account)"
  value       = local.log_archive_account_id
}

output "management_account_id" {
  description = "The AWS account ID where the CloudTrail is created (Management Account)"
  value       = local.management_account_id
}

output "is_cross_account_setup" {
  description = "Whether this is a cross-account setup (CloudTrail and S3 bucket in different accounts)"
  value       = local.log_archive_account_id != local.management_account_id
}

################################################################################
# KMS Key
################################################################################

output "kms_key_id" {
  description = "The ID of the KMS key used for CloudTrail log encryption"
  value       = local.kms_key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for CloudTrail log encryption"
  value       = try(aws_kms_key.cloudtrail[0].arn, local.kms_key_id)
}

output "kms_key_alias" {
  description = "The alias of the KMS key used for CloudTrail log encryption"
  value       = try(aws_kms_alias.cloudtrail[0].name, null)
}

output "kms_key_created" {
  description = "Whether a new KMS key was created by this module"
  value       = local.create_kms_key
}

output "sso_admin_role_arns" {
  description = "List of SSO Administrator role ARNs granted decrypt permissions on the KMS key"
  value       = local.sso_admin_role_arns
}

output "sso_admin_roles_found" {
  description = "Number of SSO Administrator roles found in the Log Archive Account"
  value       = length(local.sso_admin_role_arns)
}

################################################################################
# S3 Bucket
################################################################################

output "s3_bucket_id" {
  description = "The ID of the S3 bucket used for CloudTrail logs"
  value       = try(aws_s3_bucket.cloudtrail[0].id, null)
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for CloudTrail logs"
  value       = local.s3_bucket_arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket used for CloudTrail logs"
  value       = local.s3_bucket_name
}

output "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket used for CloudTrail logs"
  value       = try(aws_s3_bucket.cloudtrail[0].bucket_domain_name, null)
}

output "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket used for CloudTrail logs"
  value       = try(aws_s3_bucket.cloudtrail[0].bucket_regional_domain_name, null)
}

output "s3_bucket_hosted_zone_id" {
  description = "The hosted zone ID of the S3 bucket used for CloudTrail logs"
  value       = try(aws_s3_bucket.cloudtrail[0].hosted_zone_id, null)
}

output "s3_bucket_region" {
  description = "The region of the S3 bucket used for CloudTrail logs"
  value       = try(aws_s3_bucket.cloudtrail[0].region, null)
}

output "s3_bucket_kms_encrypted" {
  description = "Whether the S3 bucket is encrypted with KMS"
  value       = local.kms_key_id != null
}

################################################################################
# S3 Access Logging (SecurityHub CloudTrail.7)
################################################################################

output "s3_access_logging_enabled" {
  description = "Whether S3 access logging is enabled on the CloudTrail bucket"
  value       = var.enable_s3_access_logging && local.create_s3_bucket
}

output "access_logs_bucket_id" {
  description = "The ID of the S3 bucket used for access logs"
  value       = try(aws_s3_bucket.access_logs[0].id, null)
}

output "access_logs_bucket_name" {
  description = "The name of the S3 bucket used for access logs"
  value       = local.access_logs_bucket_name
}

output "access_logs_bucket_arn" {
  description = "The ARN of the S3 bucket used for access logs"
  value       = try(aws_s3_bucket.access_logs[0].arn, null)
}

output "access_logs_bucket_created" {
  description = "Whether a new access logs bucket was created by this module"
  value       = local.create_access_logs_bucket
}

output "access_logs_target_prefix" {
  description = "The prefix for access log objects"
  value       = var.access_logs_target_prefix
}

################################################################################
# S3 SSL Enforcement (SecurityHub S3.5)
################################################################################

output "s3_ssl_enforcement_enabled" {
  description = "Whether SSL enforcement is enabled on the CloudTrail S3 bucket (SecurityHub S3.5)"
  value       = var.enforce_ssl
}

output "access_logs_ssl_enforcement_enabled" {
  description = "Whether SSL enforcement is enabled on the access logs S3 bucket (SecurityHub S3.5)"
  value       = var.access_logs_enforce_ssl
}

################################################################################
# CloudWatch Logs
################################################################################

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for CloudTrail logs"
  value       = try(aws_cloudwatch_log_group.cloudtrail[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group for CloudTrail logs"
  value       = try(aws_cloudwatch_log_group.cloudtrail[0].arn, null)
}

output "cloudwatch_log_group_retention_in_days" {
  description = "The retention period of the CloudWatch log group for CloudTrail logs"
  value       = try(aws_cloudwatch_log_group.cloudtrail[0].retention_in_days, null)
}

output "cloudwatch_logs_role_arn" {
  description = "The ARN of the IAM role for CloudWatch Logs delivery"
  value       = try(aws_iam_role.cloudtrail_cloudwatch_logs[0].arn, null)
}

output "cloudwatch_logs_role_name" {
  description = "The name of the IAM role for CloudWatch Logs delivery"
  value       = try(aws_iam_role.cloudtrail_cloudwatch_logs[0].name, null)
}

output "cloudwatch_logs_kms_encrypted" {
  description = "Whether CloudWatch logs are encrypted with KMS"
  value       = local.cloudwatch_logs_kms_key_id != null
}

################################################################################
# IAM Policy Documents
################################################################################

# output "s3_bucket_policy_json" {
#   description = "The JSON policy document for the S3 bucket policy"
#   value       = try(data.aws_iam_policy_document.cloudtrail_s3_policy[0].json, null)
# }

# output "cloudwatch_logs_policy_json" {
#   description = "The JSON policy document for the CloudWatch logs policy"
#   value       = try(data.aws_iam_policy_document.cloudtrail_cloudwatch_logs[0].json, null)
# }

# output "kms_key_policy_json" {
#   description = "The JSON policy document for the KMS key policy"
#   value       = try(data.aws_iam_policy_document.cloudtrail_kms_policy[0].json, null)
# }
