# ============================================================================
# IAM Access Analyzer (Organization Level)
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  partition = data.aws_partition.current.partition
  # IAM services are global and should only be deployed in us-east-1
  deploy_iam_resources = data.aws_region.current.region == "us-east-1"
}

# Enable trusted service access for AWS Access Analyzer services using AWS CLI
# This is required before creating organization-level analyzers
resource "null_resource" "enable_access_analyzer_service_access" {
  count = var.create_access_analyzer && var.access_analyzer_type == "ORGANIZATION" && local.deploy_iam_resources ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      echo "Enabling AWS Access Analyzer service access in organization..."
      aws organizations enable-aws-service-access --service-principal access-analyzer.amazonaws.com
      echo "AWS Access Analyzer service access enabled successfully"
    EOT
  }
}

resource "aws_accessanalyzer_analyzer" "org" {
  count = var.create_access_analyzer && var.access_analyzer_type != null ? 1 : 0

  analyzer_name = var.access_analyzer_name
  type          = var.access_analyzer_type

  # Configuration for unused access analyzer
  dynamic "configuration" {
    for_each = var.access_analyzer_type == "ORGANIZATION_UNUSED_ACCESS" && var.access_analyzer_unused_access_configuration != null ? [1] : []
    content {
      unused_access {
        unused_access_age = var.access_analyzer_unused_access_configuration.unused_access_age
      }
    }
  }

  # Ensure service access is enabled before creating organization analyzer
  depends_on = [null_resource.enable_access_analyzer_service_access]

  tags = var.tags
}

# ============================================================================
# IAM Access Analyzer Archive Rules
# ============================================================================

resource "aws_accessanalyzer_archive_rule" "org" {
  for_each = var.create_access_analyzer && length(var.access_analyzer_archive_rules) > 0 ? var.access_analyzer_archive_rules : {}

  analyzer_name = aws_accessanalyzer_analyzer.org[0].analyzer_name
  rule_name     = each.key

  dynamic "filter" {
    for_each = each.value.filters
    content {
      criteria = filter.value.criteria
      contains = try(filter.value.contains, null)
      eq       = try(filter.value.eq, null)
      exists   = try(filter.value.exists, null)
      neq      = try(filter.value.neq, null)
    }
  }
}

# ============================================================================
# Centralized Root Access Management (Organization Level)
# ============================================================================

# Enable trusted service access for IAM services using AWS CLI
# This is required before enabling centralized root access features
resource "null_resource" "enable_iam_org_access" {
  count = var.enable_centralized_root_access && local.deploy_iam_resources ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      echo "Enabling IAM service access in organization..."
      aws organizations enable-aws-service-access --service-principal iam.amazonaws.com
      echo "IAM service access enabled successfully"
    EOT
  }
}

# Centralized Root Access Management for Organization Member Accounts
# This helps remediate Security Hub control IAM.6 by removing root credentials from member accounts
# Reference: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-enable-root-access.html
resource "aws_iam_organizations_features" "centralized_root_access" {
  count = var.enable_centralized_root_access && local.deploy_iam_resources ? 1 : 0

  enabled_features = var.centralized_root_access_features

  # Ensure IAM service access is enabled before creating the features
  depends_on = [null_resource.enable_iam_org_access]
}

# ============================================================================
# CloudFormation StackSets for Per-Account Baseline Security
# ============================================================================

# Enable trusted service access for CloudFormation service using AWS CLI
# This is required before creating service-managed stack sets
resource "null_resource" "enable_cloudformation_org_access" {
  count = var.enable_stacksets ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      echo "Enabling CloudFormation service access in organization..."
      aws cloudformation activate-organizations-access --region ${data.aws_region.current.region}
      echo "CloudFormation service access enabled successfully"
    EOT
  }
}

resource "aws_cloudformation_stack_set" "baseline" {
  count = var.enable_stacksets ? 1 : 0

  name             = var.stackset_name
  permission_model = "SERVICE_MANAGED"

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]

  template_body = file("${path.module}/templates/baseline.yaml")

  parameters = {
    # AWS Support Role Parameters
    CreateAwsSupportRole             = tostring(var.create_aws_support_role)
    AwsSupportRoleName               = var.aws_support_role_name
    AwsSupportRoleRequireMfa         = tostring(var.aws_support_role_require_mfa)
    AwsSupportRoleMaxSessionDuration = tostring(var.aws_support_role_max_session_duration)
    AwsSupportTrustedEntitiesMode    = var.aws_support_trusted_entities_mode
    AwsSupportTrustedEntities        = var.aws_support_trusted_entities

    # S3 Public Access Block Parameters
    S3BlockPublicAcls       = tostring(var.s3_pab_block_public_acls)
    S3BlockPublicPolicy     = tostring(var.s3_pab_block_public_policy)
    S3IgnorePublicAcls      = tostring(var.s3_pab_ignore_public_acls)
    S3RestrictPublicBuckets = tostring(var.s3_pab_restrict_public_buckets)

    # EBS Encryption Parameters
    EBSEncryptionByDefault = tostring(var.ebs_encryption_by_default)
    EbsDefaultKmsKeyId     = var.ebs_default_kms_key_id != null ? var.ebs_default_kms_key_id : ""

    # NEW KMS Key Creation Parameters  
    CreateEbsKmsKey         = tostring(var.create_ebs_kms_key)
    EbsKmsKeyAlias          = var.ebs_kms_key_alias
    EbsKmsKeyRotation       = tostring(var.ebs_kms_key_rotation)
    EbsKmsKeyDeletionWindow = tostring(var.ebs_kms_key_deletion_window)

    # IAM Password Policy Parameters
    CreatePasswordPolicy       = tostring(var.create_password_policy)
    PasswordMinLength          = tostring(var.password_min_length)
    PasswordRequireSymbols     = tostring(var.password_require_symbols)
    PasswordRequireNumbers     = tostring(var.password_require_numbers)
    PasswordRequireUppercase   = tostring(var.password_require_uppercase)
    PasswordRequireLowercase   = tostring(var.password_require_lowercase)
    PasswordAllowUsersToChange = tostring(var.password_allow_users_to_change)
    PasswordMaxAge             = tostring(var.password_max_age)
    PasswordReusePrevention    = tostring(var.password_reuse_prevention)
    PasswordHardExpiry         = tostring(var.password_hard_expiry)

    # IAM Access Analyzer Parameters (NEW - fixes drift)
    CreateIamAccessAnalyzer      = tostring(var.create_iam_access_analyzer)
    IamAccessAnalyzerName        = var.iam_access_analyzer_name
    IamAccessAnalyzerType        = var.iam_access_analyzer_type
    UnusedAccessAge              = tostring(var.iam_access_analyzer_unused_access_age)
    CreateArchiveRules           = tostring(var.create_iam_access_analyzer_archive_rules)
    ArchiveRuleS3BucketExclusion = var.iam_access_analyzer_s3_bucket_exclusion
  }

  # Ensure service access is enabled before creating stack set
  depends_on = [null_resource.enable_cloudformation_org_access]

  # Prevent drift for SERVICE_MANAGED StackSets - AWS Organizations manages the admin role
  lifecycle {
    ignore_changes = [
      administration_role_arn # Managed automatically by AWS Organizations
    ]
  }

  tags = var.tags
}

resource "aws_cloudformation_stack_instances" "baseline" {
  count = var.enable_stacksets ? 1 : 0

  stack_set_name = aws_cloudformation_stack_set.baseline[0].name
  regions        = var.stacksets_regions

  deployment_targets {
    organizational_unit_ids = var.stacksets_organizational_unit_ids
  }
}

module "cloudtrail_s3_logging" {
  source = "./modules/cloudtrail-s3-logging"
  providers = {
    aws.log_archive = aws.log_archive
  }

  count = var.enable_cloudtrail ? 1 : 0

  log_archive_account_id = var.log_archive_account_id

  # CloudTrail Configuration
  trail_name               = var.cloudtrail_name
  s3_bucket_name_prefix    = var.cloudtrail_s3_bucket_name_prefix
  is_organization_trail    = var.cloudtrail_is_organization_trail
  is_multi_region_trail    = true
  enable_s3_access_logging = var.cloudtrail_enable_s3_access_logging
  enforce_ssl              = var.cloudtrail_enforce_ssl
  s3_buckets_to_monitor    = var.cloudtrail_s3_buckets_to_monitor
  log_retention_days       = var.cloudtrail_log_retention_days

  # KMS Configuration
  create_kms_key = true
  kms_key_alias  = "cloudtrail-${var.cloudtrail_name}"

  # S3 Configuration
  create_s3_bucket               = true
  enable_lifecycle_configuration = true

  tags = var.tags
}


