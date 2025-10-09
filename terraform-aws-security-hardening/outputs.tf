output "cfn_stackset" {
  value = var.enable_stacksets ? {
    stack_set_name = try(aws_cloudformation_stack_set.baseline[0].name, null)
    stack_set_id   = try(aws_cloudformation_stack_set.baseline[0].stack_set_id, null)
    stack_set_arn  = try(aws_cloudformation_stack_set.baseline[0].arn, null)
  } : null
  description = "CloudFormation StackSet outputs"
}

# Individual resource outputs for validation
output "access_analyzer_arn" {
  value       = try(aws_accessanalyzer_analyzer.org[0].arn, null)
  description = "IAM Access Analyzer ARN"
}

output "access_analyzer_archive_rules" {
  value       = aws_accessanalyzer_archive_rule.org
  description = "Map of Access Analyzer archive rules created"
}

# Centralized Root Access Management Outputs
output "centralized_root_access_enabled" {
  value       = var.enable_centralized_root_access && length(aws_iam_organizations_features.centralized_root_access) > 0
  description = "Whether centralized root access management is enabled"
}

output "centralized_root_access_features" {
  value       = try(aws_iam_organizations_features.centralized_root_access[0].enabled_features, [])
  description = "List of enabled centralized root access features"
}

output "centralized_root_access_organization_id" {
  value       = try(aws_iam_organizations_features.centralized_root_access[0].id, null)
  description = "AWS Organization ID where centralized root access is enabled"
}


output "stackset_name" {
  value       = try(aws_cloudformation_stack_set.baseline[0].name, null)
  description = "CloudFormation StackSet name for per-account baselines"
}

################################################################################
# CloudTrail S3 Logging Outputs
################################################################################

output "cloudtrail" {
  value       = try(module.cloudtrail_s3_logging[0], null)
  description = "CloudTrail S3 logging submodule outputs"
}

output "cloudtrail_arn" {
  value       = try(module.cloudtrail_s3_logging[0].cloudtrail_arn, null)
  description = "CloudTrail ARN"
}

output "cloudtrail_s3_bucket_name" {
  value       = try(module.cloudtrail_s3_logging[0].s3_bucket_name, null)
  description = "CloudTrail S3 bucket name"
}

output "cloudtrail_kms_key_arn" {
  value       = try(module.cloudtrail_s3_logging[0].kms_key_arn, null)
  description = "CloudTrail KMS key ARN"
}

# Enhanced KMS Key Configuration Outputs (NEW)
output "kms_key_configuration" {
  value = {
    create_ebs_kms_key          = var.create_ebs_kms_key
    ebs_kms_key_alias           = var.ebs_kms_key_alias
    ebs_kms_key_rotation        = var.ebs_kms_key_rotation
    ebs_kms_key_deletion_window = var.ebs_kms_key_deletion_window
    ebs_default_kms_key_id      = var.ebs_default_kms_key_id
  }
  description = "KMS key configuration for EBS encryption"
}

# Compliance summary
output "compliance_summary" {
  value = {
    # Organization-level controls (Management Account)
    access_analyzer_deployed        = var.create_access_analyzer
    centralized_root_access_enabled = var.enable_centralized_root_access

    # CloudTrail S3 Logging (Management Account)
    cloudtrail_s3_logging_enabled = var.enable_cloudtrail

    # Per-account controls (via StackSets)
    s3_public_access_blocked = var.enable_stacksets && var.s3_pab_block_public_acls && var.s3_pab_block_public_policy
    ebs_encryption_enabled   = var.enable_stacksets && var.ebs_encryption_by_default
    password_policy_enabled  = var.enable_stacksets && var.create_password_policy
    aws_support_role_enabled = var.enable_stacksets && var.create_aws_support_role

    # NEW Enhanced KMS Features
    ebs_custom_kms_key_enabled = var.enable_stacksets && var.create_ebs_kms_key

    # SecurityHub Compliance Coverage
    securityhub_controls_addressed = {
      s3_1_public_access_blocked = var.enable_stacksets && var.s3_pab_block_public_acls
      s3_5_ssl_enforcement       = var.enable_cloudtrail && var.cloudtrail_enforce_ssl
      s3_22_object_write_events  = var.enable_cloudtrail
      s3_23_object_read_events   = var.enable_cloudtrail
      ec2_7_ebs_encryption       = var.enable_stacksets && var.ebs_encryption_by_default
      iam_6_hardware_mfa_root    = var.enable_centralized_root_access
      iam_7_password_policy      = var.enable_stacksets && var.create_password_policy
      iam_18_support_role        = var.enable_stacksets && var.create_aws_support_role
      cloudtrail_7_s3_logging    = var.enable_cloudtrail && var.cloudtrail_enable_s3_access_logging
    }

    # Coverage
    targeted_organizational_units = length(var.stacksets_organizational_unit_ids)
    deployment_regions            = length(var.stacksets_regions)
  }
  description = "Summary of compliance controls deployed"
}


