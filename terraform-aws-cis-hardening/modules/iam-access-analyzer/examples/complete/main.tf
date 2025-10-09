provider "aws" {
  region = var.region
}

# External access analyzer for account level
module "account_external_analyzer" {
  source = "../../"

  analyzer_name = "${var.name}-account-external"
  type          = "ACCOUNT"

  # Archive rules to automatically handle specific findings
  archive_rules = {
    "ArchiveKnownCrossAccountAccess" = {
      filters = [
        {
          criteria = "principal.AWS"
          contains = ["arn:aws:iam::${var.trusted_account_id}:root"]
        }
      ]
    }
    "ArchivePublicS3ReadOnly" = {
      filters = [
        {
          criteria = "resourceType"
          eq       = ["AWS::S3::Bucket"]
        },
        {
          criteria = "isPublic"
          eq       = ["true"]
        },
        {
          criteria = "action"
          contains = ["s3:GetObject"]
        }
      ]
    }
  }

  tags = local.tags
}

# Organization external access analyzer (requires organization permissions)
module "organization_external_analyzer" {
  count = var.enable_organization_analyzer ? 1 : 0

  source = "../../"

  analyzer_name = "${var.name}-org-external"
  type          = "ORGANIZATION"

  # Archive rules for organization-wide findings
  archive_rules = {
    "ArchiveExpectedCrossOrgAccess" = {
      filters = [
        {
          criteria = "principal.AWS"
          contains = var.expected_external_principals
        }
      ]
    }
  }

  tags = local.tags
}

# Organization unused access analyzer (paid feature)
module "organization_unused_analyzer" {
  count = var.enable_unused_access_analyzer ? 1 : 0

  source = "../../"

  analyzer_name = "${var.name}-org-unused"
  type          = "ORGANIZATION_UNUSED_ACCESS"

  unused_access_configuration = {
    unused_access_age = var.unused_access_age_days
  }

  tags = local.tags
}

# Example S3 bucket with policy that will be detected by Access Analyzer
resource "aws_s3_bucket" "example" {
  bucket = "${var.name}-access-analyzer-example"

  tags = local.tags
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountRead"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.trusted_account_id}:root"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.example.arn}/*"
      }
    ]
  })
}

# Example IAM role with cross-account trust policy
resource "aws_iam_role" "example" {
  name = "${var.name}-cross-account-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.trusted_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "example" {
  name = "${var.name}-policy"
  role = aws_iam_role.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
      }
    ]
  })
}

locals {
  tags = {
    Name        = var.name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Example     = "IAM-Access-Analyzer"
  }
}
