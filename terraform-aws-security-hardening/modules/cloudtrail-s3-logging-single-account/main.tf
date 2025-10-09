# CloudTrail S3 Logging Module for SecurityHub Compliance
# Addresses: S3.22 (object-level write events), S3.23 (object-level read events), 
# CloudTrail.7 (S3 access logging), S3.5 (SSL enforcement)

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.region

  # Generate unique bucket name with random suffix
  bucket_name_base = var.s3_bucket_name_prefix != null ? "${var.s3_bucket_name_prefix}-cloudtrail" : "org-cloudtrail"

  # S3 access logging configuration
  create_access_logs_bucket = var.enable_s3_access_logging && var.create_access_logs_bucket
  access_logs_bucket_name   = local.create_access_logs_bucket ? "${local.bucket_name_base}-access-logs-${local.account_id}-${random_string.bucket_suffix.result}" : null
}

################################################################################
# Random suffix for unique bucket names
################################################################################

resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

################################################################################
# KMS Key for CloudTrail Encryption
################################################################################

resource "aws_kms_key" "cloudtrail" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key for CloudTrail S3 logging encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_rotation

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableIAMUserPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${local.partition}:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudTrailEncryption"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${var.trail_name}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_kms_alias" "cloudtrail" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}

################################################################################
# S3 Bucket for CloudTrail Logs
################################################################################

resource "aws_s3_bucket" "cloudtrail" {
  count = var.create_s3_bucket ? 1 : 0

  bucket        = "${local.bucket_name_base}-${local.account_id}-${random_string.bucket_suffix.result}"
  force_destroy = var.force_destroy_s3_bucket

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.create_kms_key ? aws_kms_key.cloudtrail[0].arn : var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  count = var.create_s3_bucket && var.enable_lifecycle_configuration ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    id     = "cloudtrail_lifecycle"
    status = "Enabled"

    # Empty filter block means rule applies to all objects in the bucket
    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    dynamic "expiration" {
      for_each = var.log_retention_days > 0 ? [1] : []
      content {
        days = var.log_retention_days
      }
    }
  }
}

################################################################################
# S3 Bucket Policy for CloudTrail and SSL Enforcement (SecurityHub S3.5)
################################################################################

data "aws_iam_policy_document" "cloudtrail_s3_policy" {
  count = var.create_s3_bucket ? 1 : 0

  # Allow CloudTrail to write logs
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail[0].arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${var.trail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail[0].arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${var.trail_name}"]
    }
  }

  # SSL/HTTPS enforcement (SecurityHub S3.5 compliance)
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
        aws_s3_bucket.cloudtrail[0].arn,
        "${aws_s3_bucket.cloudtrail[0].arn}/*"
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
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id
  policy = data.aws_iam_policy_document.cloudtrail_s3_policy[0].json
}

################################################################################
# S3 Access Logging Bucket (SecurityHub CloudTrail.7 compliance)
################################################################################

resource "aws_s3_bucket" "access_logs" {
  count = local.create_access_logs_bucket ? 1 : 0

  bucket        = local.access_logs_bucket_name
  force_destroy = var.access_logs_bucket_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count = local.create_access_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count = local.create_access_logs_bucket ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.create_kms_key ? aws_kms_key.cloudtrail[0].arn : var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  count = local.create_access_logs_bucket && var.access_logs_retention_days > 0 ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    id     = "access_logs_lifecycle"
    status = "Enabled"

    # Empty filter block means rule applies to all objects in the bucket
    filter {}

    expiration {
      days = var.access_logs_retention_days
    }
  }
}

# Configure S3 access logging on the CloudTrail bucket
resource "aws_s3_bucket_logging" "cloudtrail" {
  count = var.create_s3_bucket && var.enable_s3_access_logging ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  target_bucket = local.create_access_logs_bucket ? aws_s3_bucket.access_logs[0].id : var.access_logs_bucket_name
  target_prefix = var.access_logs_target_prefix
}

################################################################################
# CloudTrail with S3 Data Events (SecurityHub S3.22 and S3.23)
################################################################################

resource "aws_cloudtrail" "this" {
  count = var.create_cloudtrail ? 1 : 0

  name                          = var.trail_name
  s3_bucket_name                = var.create_s3_bucket ? aws_s3_bucket.cloudtrail[0].id : var.s3_bucket_name
  s3_key_prefix                 = var.s3_key_prefix
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  is_organization_trail         = var.is_organization_trail
  enable_logging                = var.enable_logging
  enable_log_file_validation    = var.enable_log_file_validation
  kms_key_id                    = var.create_kms_key ? aws_kms_key.cloudtrail[0].arn : var.kms_key_id

  # Advanced event selectors for S3 data events (S3.22 and S3.23)
  advanced_event_selector {
    name = "S3 Data Events - Read Operations (S3.23)"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }

    field_selector {
      field  = "readOnly"
      equals = ["true"]
    }

    # Monitor specific buckets if provided, otherwise all buckets
    dynamic "field_selector" {
      for_each = length(var.s3_buckets_to_monitor) > 0 ? [1] : []
      content {
        field  = "resources.ARN"
        equals = var.s3_buckets_to_monitor
      }
    }
  }

  advanced_event_selector {
    name = "S3 Data Events - Write Operations (S3.22)"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }

    field_selector {
      field  = "readOnly"
      equals = ["false"]
    }

    # Monitor specific buckets if provided, otherwise all buckets
    dynamic "field_selector" {
      for_each = length(var.s3_buckets_to_monitor) > 0 ? [1] : []
      content {
        field  = "resources.ARN"
        equals = var.s3_buckets_to_monitor
      }
    }
  }

  tags = var.tags
}
