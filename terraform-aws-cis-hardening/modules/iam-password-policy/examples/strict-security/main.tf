provider "aws" {
  region = "us-east-1"
}

# Strict security configuration for high-security environments
module "strict_iam_password_policy" {
  source = "../../"

  # Strict password requirements
  minimum_password_length   = 20 # Very long passwords
  password_reuse_prevention = 24 # Maximum history (AWS limit)
  max_password_age          = 30 # Monthly password changes

  # Character complexity requirements (all enabled)
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers              = true
  require_symbols              = true

  # User management settings
  allow_users_to_change_password = true
  hard_expiry                    = true # Strict expiration enforcement
}

# Output the strict policy configuration
output "strict_password_policy_summary" {
  description = "Summary of the strict IAM password policy configuration"
  value = {
    minimum_password_length        = module.strict_iam_password_policy.minimum_password_length
    require_lowercase_characters   = module.strict_iam_password_policy.require_lowercase_characters
    require_uppercase_characters   = module.strict_iam_password_policy.require_uppercase_characters
    require_numbers                = module.strict_iam_password_policy.require_numbers
    require_symbols                = module.strict_iam_password_policy.require_symbols
    allow_users_to_change_password = module.strict_iam_password_policy.allow_users_to_change_password
    max_password_age               = module.strict_iam_password_policy.max_password_age
    password_reuse_prevention      = module.strict_iam_password_policy.password_reuse_prevention
    hard_expiry                    = module.strict_iam_password_policy.hard_expiry
  }
}

# Additional output for compliance reporting
output "compliance_summary" {
  description = "Compliance summary for audit purposes"
  value = {
    cis_benchmark_1_9_compliant  = module.strict_iam_password_policy.minimum_password_length >= 14
    cis_benchmark_1_10_compliant = module.strict_iam_password_policy.password_reuse_prevention > 0
    nist_compliant_complexity = (
      module.strict_iam_password_policy.require_lowercase_characters &&
      module.strict_iam_password_policy.require_uppercase_characters &&
      module.strict_iam_password_policy.require_numbers &&
      module.strict_iam_password_policy.require_symbols
    )
    password_length_exceeds_minimum = module.strict_iam_password_policy.minimum_password_length >= 20
    maximum_password_history        = module.strict_iam_password_policy.password_reuse_prevention == 24
  }
}
