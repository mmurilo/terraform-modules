provider "aws" {
  region = "us-east-1"
}

# Basic usage with default settings
module "iam_password_policy" {
  source = "../../"
}

# Output the password policy configuration
output "password_policy_summary" {
  description = "Summary of the IAM password policy configuration"
  value = {
    minimum_password_length        = module.iam_password_policy.minimum_password_length
    require_lowercase_characters   = module.iam_password_policy.require_lowercase_characters
    require_uppercase_characters   = module.iam_password_policy.require_uppercase_characters
    require_numbers                = module.iam_password_policy.require_numbers
    require_symbols                = module.iam_password_policy.require_symbols
    allow_users_to_change_password = module.iam_password_policy.allow_users_to_change_password
    max_password_age               = module.iam_password_policy.max_password_age
    password_reuse_prevention      = module.iam_password_policy.password_reuse_prevention
    hard_expiry                    = module.iam_password_policy.hard_expiry
  }
}
