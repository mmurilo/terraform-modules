data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

# Data source for Log Archive Account (when using cross-account setup)
data "aws_caller_identity" "log_archive" {
  count    = var.log_archive_account_id != null ? 1 : 0
  provider = aws.log_archive
}

# Data source to find SSO Administrator role in Log Archive Account
data "aws_iam_roles" "sso_admin_log_archive" {
  count    = local.is_cross_account ? 1 : 0
  provider = aws.log_archive

  name_regex = "AWSReservedSSO_AWSAdministratorAccess_.*"
}

locals {
  create_cloudtrail       = var.create_cloudtrail
  create_s3_bucket        = var.create_s3_bucket
  create_s3_bucket_policy = var.create_s3_bucket_policy
  create_kms_key          = var.create_kms_key && local.create_cloudtrail

  # Account IDs - use provided values or fall back to current account
  current_account_id     = data.aws_caller_identity.current.account_id
  log_archive_account_id = var.log_archive_account_id != null ? var.log_archive_account_id : local.current_account_id
  management_account_id  = var.management_account_id != null ? var.management_account_id : local.current_account_id

  # Determine if this is a cross-account setup
  is_cross_account = var.log_archive_account_id != null && var.log_archive_account_id != local.current_account_id

  # SSO Administrator role ARNs from Log Archive Account
  sso_admin_role_arns = local.is_cross_account && length(data.aws_iam_roles.sso_admin_log_archive) > 0 ? [
    for role in data.aws_iam_roles.sso_admin_log_archive[0].arns : role
  ] : []

  # KMS key configuration
  kms_key_id    = local.create_kms_key ? aws_kms_key.cloudtrail[0].arn : var.kms_key_id
  kms_key_alias = var.kms_key_alias != null ? var.kms_key_alias : "cloudtrail-${local.trail_name}"

  # S3 Access Logging configuration (SecurityHub CloudTrail.7)
  create_access_logs_bucket = var.enable_s3_access_logging && var.create_access_logs_bucket && local.create_s3_bucket
  access_logs_bucket_name = var.access_logs_bucket_name != null ? var.access_logs_bucket_name : (
    local.create_access_logs_bucket ? aws_s3_bucket.access_logs[0].id : null
  )

  # CloudWatch Logs KMS key - use CloudTrail key if not specified
  cloudwatch_logs_kms_key_id = var.cloudwatch_logs_kms_key_id != null ? var.cloudwatch_logs_kms_key_id : local.kms_key_id

  # Use provided bucket name or create a default one
  s3_bucket_name = var.s3_bucket_name != null ? var.s3_bucket_name : (
    local.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].id : null
  )

  # Default trail name if not provided
  trail_name = var.trail_name != null ? var.trail_name : "s3-data-events-trail"

  # CloudTrail ARN - always uses management account (where trail is created)
  trail_arn = "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${local.management_account_id}:trail/${local.trail_name}"

  # S3 bucket ARN - uses log archive account if specified
  s3_bucket_arn = local.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].arn : "arn:aws:s3:::${local.s3_bucket_name}"
}

################################################################################
# KMS Key for CloudTrail (in Management Account)
################################################################################

data "aws_iam_policy_document" "cloudtrail_kms_policy" {
  count = local.create_kms_key ? 1 : 0

  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${local.management_account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudTrailEncryption"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = [local.trail_arn]
    }
  }

  # Allow CloudTrail to create grants for the key (needed for some operations)
  statement {
    sid    = "AllowCloudTrailCreateGrant"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "kms:CreateGrant"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  # Additional permissions for organization trails
  dynamic "statement" {
    for_each = var.is_organization_trail ? [1] : []
    content {
      sid    = "AllowCloudTrailEncryptionOrganization"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
      }

      actions = [
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:Decrypt"
      ]

      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:SourceArn"
        values   = [local.trail_arn]
      }
    }
  }

  # Allow SSO Administrator roles from Log Archive Account to decrypt CloudTrail logs
  dynamic "statement" {
    for_each = length(local.sso_admin_role_arns) > 0 ? [1] : []
    content {
      sid    = "AllowSSOAdministratorDecrypt"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = local.sso_admin_role_arns
      }

      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey*"
      ]

      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["s3.${data.aws_region.current.region}.amazonaws.com"]
      }
    }
  }

  # Allow CloudWatch Logs service to use the key for log group encryption
  dynamic "statement" {
    for_each = var.enable_cloudwatch_logs ? [1] : []
    content {
      sid    = "AllowCloudWatchLogsEncryption"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]

      resources = ["*"]

      condition {
        test     = "ArnLike"
        variable = "kms:EncryptionContext:aws:logs:arn"
        values   = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${local.management_account_id}:log-group:/aws/cloudtrail/*"]
      }
    }
  }
}

resource "aws_kms_key" "cloudtrail" {
  count = local.create_kms_key ? 1 : 0

  description             = "KMS key for CloudTrail S3 data events log encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_rotation
  policy                  = data.aws_iam_policy_document.cloudtrail_kms_policy[0].json

  tags = merge(
    var.tags,
    {
      Name    = "CloudTrail-S3-Data-Events-Encryption-Key"
      Purpose = "CloudTrail-Log-Encryption"
      Service = "CloudTrail"
      account = "log_archive"
    }
  )
}

resource "aws_kms_alias" "cloudtrail" {
  count = local.create_kms_key ? 1 : 0

  name          = "alias/${local.kms_key_alias}"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}

################################################################################
# Random suffix for bucket names
################################################################################

resource "random_string" "bucket_suffix" {
  count = local.create_cloudtrail && local.create_s3_bucket ? 1 : 0

  length  = 4
  special = false
  upper   = false
}

################################################################################
# S3 Bucket for CloudTrail Logs (in Log Archive Account)
################################################################################

resource "aws_s3_bucket" "cloudtrail" {
  count = local.create_cloudtrail && local.create_s3_bucket ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket        = var.s3_bucket_name_prefix != null ? "${var.s3_bucket_name_prefix}-cloudtrail-logs-${local.log_archive_account_id}-${random_string.bucket_suffix[0].result}" : "cloudtrail-logs-${local.log_archive_account_id}-${random_string.bucket_suffix[0].result}"
  force_destroy = var.force_destroy_s3_bucket

  tags = merge(
    var.tags,
    {
      Name    = "CloudTrail-S3-Data-Events-Logs"
      Purpose = "Control-Tower-CloudTrail-Logs"
      account = "log_archive"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count = local.create_cloudtrail && local.create_s3_bucket ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count = local.create_cloudtrail && local.create_s3_bucket ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count = local.create_cloudtrail && local.create_s3_bucket ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.cloudtrail[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  count = local.create_cloudtrail && local.create_s3_bucket && var.enable_lifecycle_configuration ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    id     = "cloudtrail_log_lifecycle"
    status = "Enabled"

    # Apply to all objects in the bucket
    filter {}

    # Transition to IA after 30 days
    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier after 90 days
    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    # Transition to Deep Archive after 365 days
    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    # Delete after specified retention period
    dynamic "expiration" {
      for_each = var.log_retention_days != null ? [1] : []
      content {
        days = var.log_retention_days
      }
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

################################################################################
# S3 Bucket Policy for CloudTrail (Cross-Account Support)
################################################################################

data "aws_iam_policy_document" "cloudtrail_s3_policy" {
  count = local.create_cloudtrail && local.create_s3_bucket_policy ? 1 : 0

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [local.s3_bucket_arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]
    resources = [
      "${local.s3_bucket_arn}/${var.s3_key_prefix}AWSLogs/${local.management_account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  # Additional statement for organization trails to allow writes from all member accounts
  dynamic "statement" {
    for_each = var.is_organization_trail ? [1] : []
    content {
      sid    = "AWSCloudTrailWriteOrganization"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
      }

      actions = ["s3:PutObject"]
      resources = [
        "${local.s3_bucket_arn}/${var.s3_key_prefix}AWSLogs/*"
      ]

      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceArn"
        values   = [local.trail_arn]
      }
    }
  }

  # SSL enforcement statement (SecurityHub S3.5)
  dynamic "statement" {
    for_each = var.enforce_ssl ? [1] : []
    content {
      sid    = "DenyInsecureConnections"
      effect = "Deny"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions = ["s3:*"]
      resources = [
        local.s3_bucket_arn,
        "${local.s3_bucket_arn}/*"
      ]

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count = local.create_cloudtrail && local.create_s3_bucket_policy ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = local.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].id : local.s3_bucket_name
  policy = data.aws_iam_policy_document.cloudtrail_s3_policy[0].json

  depends_on = [aws_s3_bucket_public_access_block.cloudtrail]
}

################################################################################
# S3 Access Logs Bucket (SecurityHub CloudTrail.7)
################################################################################

resource "aws_s3_bucket" "access_logs" {
  count = local.create_access_logs_bucket ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket        = var.s3_bucket_name_prefix != null ? "${var.s3_bucket_name_prefix}-cloudtrail-access-logs-${local.log_archive_account_id}-${random_string.bucket_suffix[0].result}" : "cloudtrail-access-logs-${local.log_archive_account_id}-${random_string.bucket_suffix[0].result}"
  force_destroy = var.access_logs_bucket_force_destroy

  tags = merge(
    var.tags,
    {
      Name    = "CloudTrail-S3-Access-Logs"
      Purpose = "CloudTrail-S3-Access-Logging"
      account = "log_archive"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count = local.create_access_logs_bucket ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count = local.create_access_logs_bucket ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "access_logs" {
  count = local.create_access_logs_bucket ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.access_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  count = local.create_access_logs_bucket && var.access_logs_bucket_lifecycle_enabled ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    id     = "access_logs_lifecycle"
    status = "Enabled"

    # Apply to all objects in the bucket
    filter {}

    # Transition to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier after 60 days
    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    # Delete after specified retention period
    dynamic "expiration" {
      for_each = var.access_logs_retention_days != null ? [1] : []
      content {
        days = var.access_logs_retention_days
      }
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

################################################################################
# S3 Bucket Access Logging Configuration (SecurityHub CloudTrail.7)
################################################################################

resource "aws_s3_bucket_logging" "cloudtrail" {
  count = local.create_cloudtrail && local.create_s3_bucket && var.enable_s3_access_logging ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.cloudtrail[0].id

  target_bucket = local.access_logs_bucket_name
  target_prefix = var.access_logs_target_prefix

  depends_on = [
    aws_s3_bucket.access_logs,
    aws_s3_bucket_public_access_block.cloudtrail
  ]
}

################################################################################
# S3 Access Logs Bucket Policy - SSL Enforcement (SecurityHub S3.5)
################################################################################

data "aws_iam_policy_document" "access_logs_s3_policy" {
  count = local.create_access_logs_bucket && var.access_logs_enforce_ssl ? 1 : 0

  # SSL enforcement statement (SecurityHub S3.5)
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.access_logs[0].arn,
      "${aws_s3_bucket.access_logs[0].arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  count = local.create_access_logs_bucket && var.access_logs_enforce_ssl ? 1 : 0

  # Use log archive provider if cross-account, otherwise use default provider
  provider = aws.log_archive

  bucket = aws_s3_bucket.access_logs[0].id
  policy = data.aws_iam_policy_document.access_logs_s3_policy[0].json

  depends_on = [aws_s3_bucket_public_access_block.access_logs]
}

################################################################################
# CloudWatch Logs (optional) - Always in Management Account
################################################################################

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = local.create_cloudtrail && var.enable_cloudwatch_logs ? 1 : 0

  name              = "/aws/cloudtrail/${local.trail_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = local.cloudwatch_logs_kms_key_id

  tags = var.tags
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  count = local.create_cloudtrail && var.enable_cloudwatch_logs ? 1 : 0

  statement {
    sid    = "AWSCloudTrailLogsPolicy"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${local.management_account_id}:log-group:/aws/cloudtrail/${local.trail_name}:*"
    ]
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch_logs" {
  count = local.create_cloudtrail && var.enable_cloudwatch_logs ? 1 : 0

  name = "${local.trail_name}-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Customer Managed Policy for CloudTrail CloudWatch Logs (CIS 1.15 Compliant)
resource "aws_iam_policy" "cloudtrail_cloudwatch_logs" {
  count = local.create_cloudtrail && var.enable_cloudwatch_logs ? 1 : 0

  name        = "${local.trail_name}-cloudwatch-logs-policy"
  description = "Managed policy for CloudTrail CloudWatch Logs permissions - CIS 1.15 compliant"
  policy      = data.aws_iam_policy_document.cloudtrail_cloudwatch_logs[0].json

  tags = var.tags
}

# Attach the managed policy to the role
resource "aws_iam_role_policy_attachment" "cloudtrail_cloudwatch_logs" {
  count = local.create_cloudtrail && var.enable_cloudwatch_logs ? 1 : 0

  role       = aws_iam_role.cloudtrail_cloudwatch_logs[0].name
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_logs[0].arn
}

################################################################################
# CloudTrail (Always in Management Account)
################################################################################

resource "aws_cloudtrail" "this" {
  count = local.create_cloudtrail ? 1 : 0

  name                          = local.trail_name
  s3_bucket_name                = local.s3_bucket_name
  s3_key_prefix                 = var.s3_key_prefix
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail
  enable_logging                = var.enable_logging
  enable_log_file_validation    = var.enable_log_file_validation
  kms_key_id                    = local.kms_key_id
  sns_topic_name                = var.sns_topic_name

  # CloudWatch Logs configuration
  cloud_watch_logs_group_arn = var.enable_cloudwatch_logs ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : null
  cloud_watch_logs_role_arn  = var.enable_cloudwatch_logs ? aws_iam_role.cloudtrail_cloudwatch_logs[0].arn : null

  # Advanced event selectors for S3 data events - addresses S3.22 and S3.23
  # This configuration logs both read and write events for S3 objects
  advanced_event_selector {
    name = "S3 Data Events - Read Operations (S3.23)"

    # Filter for Data events (not Management events)
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    # Filter for S3 Object resource type
    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }

    # Filter for read-only operations
    field_selector {
      field  = "readOnly"
      equals = ["true"]
    }

    # Include/exclude specific S3 buckets for read events
    dynamic "field_selector" {
      for_each = length(var.s3_buckets_to_monitor) > 0 ? [1] : []
      content {
        field       = "resources.ARN"
        starts_with = [for bucket in var.s3_buckets_to_monitor : "${bucket}/"]
      }
    }

    dynamic "field_selector" {
      for_each = length(var.s3_buckets_to_exclude) > 0 ? [1] : []
      content {
        field           = "resources.ARN"
        not_starts_with = [for bucket in var.s3_buckets_to_exclude : "${bucket}/"]
      }
    }
  }

  advanced_event_selector {
    name = "S3 Data Events - Write Operations (S3.22)"

    # Filter for Data events (not Management events)
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    # Filter for S3 Object resource type
    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }

    # Filter for write operations
    field_selector {
      field  = "readOnly"
      equals = ["false"]
    }

    # Include/exclude specific S3 buckets for write events
    dynamic "field_selector" {
      for_each = length(var.s3_buckets_to_monitor) > 0 ? [1] : []
      content {
        field       = "resources.ARN"
        starts_with = [for bucket in var.s3_buckets_to_monitor : "${bucket}/"]
      }
    }

    dynamic "field_selector" {
      for_each = length(var.s3_buckets_to_exclude) > 0 ? [1] : []
      content {
        field           = "resources.ARN"
        not_starts_with = [for bucket in var.s3_buckets_to_exclude : "${bucket}/"]
      }
    }
  }

  # Optional: Include Management events if requested
  dynamic "advanced_event_selector" {
    for_each = var.include_management_events ? [1] : []
    content {
      name = "Management Events"

      field_selector {
        field  = "eventCategory"
        equals = ["Management"]
      }
    }
  }

  tags = var.tags

  depends_on = [
    aws_s3_bucket_policy.cloudtrail,
    aws_iam_role_policy_attachment.cloudtrail_cloudwatch_logs
  ]
}
