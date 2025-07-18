# ============================================================================
# Basic Security Controls Example
# ============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "security-controls"
      ManagedBy   = "terraform"
      Example     = "basic"
    }
  }
}

# ============================================================================
# Deploy Security Controls with Default Settings
# ============================================================================

module "security_controls" {
  source = "../../"

  # Enable both SecurityHub controls with secure defaults
  enable_s3_account_public_access_block = true
  enable_ebs_encryption_by_default      = true

  tags = {
    Name        = "security-controls-basic-example"
    Environment = var.environment
    Purpose     = "SecurityHub compliance demonstration"
  }
}

# ============================================================================
# Outputs
# ============================================================================

output "compliance_summary" {
  description = "Summary of deployed security controls"
  value       = module.security_controls.security_controls_summary
}

output "s3_settings" {
  description = "S3 public access block settings"
  value       = module.security_controls.s3_public_access_settings
}

output "ebs_encryption_status" {
  description = "EBS encryption configuration status"
  value = {
    enabled = module.security_controls.ebs_encryption_by_default_enabled
    region  = module.security_controls.ebs_encryption_by_default_id
    kms_key = module.security_controls.ebs_default_kms_key_arn
  }
}
