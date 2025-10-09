# Example: CloudTrail S3 Logging for AWS Control Tower
# Deploy this from the Management Account

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure providers
# Default provider - Management Account (for CloudTrail, CloudWatch, IAM)
provider "aws" {
  region = var.aws_region
  # Uses default credentials/profile for Management Account
}

# Log Archive Account provider (for S3 bucket creation)
provider "aws" {
  alias  = "log_archive"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.log_archive_account_id}:role/${var.cross_account_role_name}"
  }
}

# Get current account information
data "aws_caller_identity" "current" {}

# Deploy the CloudTrail S3 logging module
module "cloudtrail_s3_logging" {
  source = "../../"

  # Pass the log_archive provider explicitly
  providers = {
    aws.log_archive = aws.log_archive
  }

  trail_name = var.trail_name

  # Control Tower multi-account configuration
  log_archive_account_id = var.log_archive_account_id
  management_account_id  = data.aws_caller_identity.current.account_id

  # Organization trail for all Control Tower accounts
  is_organization_trail = true
  is_multi_region_trail = true

  # S3 bucket configuration
  create_s3_bucket      = true
  s3_bucket_name_prefix = var.s3_bucket_prefix
  s3_key_prefix         = "s3-data-events/"

  # KMS encryption configuration
  create_kms_key          = var.create_kms_key
  kms_key_alias           = var.kms_key_alias
  kms_key_rotation        = var.kms_key_rotation
  kms_key_deletion_window = var.kms_key_deletion_window

  # Lifecycle management
  enable_lifecycle_configuration = true
  log_retention_days             = var.log_retention_days

  # Security best practices
  enable_log_file_validation = true

  # Optional: Enable CloudWatch Logs
  enable_cloudwatch_logs            = var.enable_cloudwatch_logs
  cloudwatch_logs_retention_in_days = var.cloudwatch_retention_days

  tags = {
    Environment    = var.environment
    Purpose        = "SecurityHub-S3-Compliance"
    ControlTower   = "true"
    LogDestination = "log-archive-account"
    ManagedBy      = "terraform"
  }
}
