locals {
  bucket_lifecycle = [
    {
      id = "Delete versioned objects after ${var.lifecycle_delete} days"
      filter = {
        prefix = ""
      }
      noncurrent_version_expiration = {
        noncurrent_days = var.lifecycle_delete
      }
      status = "Enabled"
    }
  ]
}

module "tf_state" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "= 4.1.2" #! FIXME

  bucket        = local.bucket_name
  attach_policy = true
  policy        = data.aws_iam_policy_document.tfstate_bucket.json
  force_destroy = false

  lifecycle_rule = local.bucket_lifecycle

  versioning = {
    status     = true
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = local.bucket_name
    Description = "S3 bucket for Terrafrom state"
    managed_by  = var.creator
  }
}


data "aws_iam_policy_document" "tfstate_bucket" {

  statement {
    sid = "DenyIncorrectEncryptionHeader"

    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "AES256",
        "aws:kms"
      ]
    }
  }

  statement {
    sid = "DenyUnEncryptedObjectUploads"

    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "true"
      ]
    }
  }

  statement {
    sid = "EnforceTlsRequestsOnly"

    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
