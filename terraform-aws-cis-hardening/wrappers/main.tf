module "wrapper" {
  source = "../"

  for_each = var.items

  # General Variables
  tags = try(each.value.tags, var.defaults.tags, {})

  # Module Control Variables
  create_iam_access_analyzer = try(each.value.create_iam_access_analyzer, var.defaults.create_iam_access_analyzer, true)
  create_iam_password_policy = try(each.value.create_iam_password_policy, var.defaults.create_iam_password_policy, true)
  create_security_controls   = try(each.value.create_security_controls, var.defaults.create_security_controls, true)

  # IAM Access Analyzer Module Variables
  iam_access_analyzer_name                        = try(each.value.iam_access_analyzer_name, var.defaults.iam_access_analyzer_name, null)
  iam_access_analyzer_type                        = try(each.value.iam_access_analyzer_type, var.defaults.iam_access_analyzer_type, "ACCOUNT")
  iam_access_analyzer_unused_access_configuration = try(each.value.iam_access_analyzer_unused_access_configuration, var.defaults.iam_access_analyzer_unused_access_configuration, null)
  iam_access_analyzer_archive_rules               = try(each.value.iam_access_analyzer_archive_rules, var.defaults.iam_access_analyzer_archive_rules, {})

  # Security Controls Module Variables - S3 Account Public Access Block
  security_controls_enable_s3_account_public_access_block = try(each.value.security_controls_enable_s3_account_public_access_block, var.defaults.security_controls_enable_s3_account_public_access_block, true)
  security_controls_s3_block_public_acls                  = try(each.value.security_controls_s3_block_public_acls, var.defaults.security_controls_s3_block_public_acls, true)
  security_controls_s3_block_public_policy                = try(each.value.security_controls_s3_block_public_policy, var.defaults.security_controls_s3_block_public_policy, true)
  security_controls_s3_ignore_public_acls                 = try(each.value.security_controls_s3_ignore_public_acls, var.defaults.security_controls_s3_ignore_public_acls, true)
  security_controls_s3_restrict_public_buckets            = try(each.value.security_controls_s3_restrict_public_buckets, var.defaults.security_controls_s3_restrict_public_buckets, true)

  # Security Controls Module Variables - EBS Encryption
  security_controls_enable_ebs_encryption_by_default = try(each.value.security_controls_enable_ebs_encryption_by_default, var.defaults.security_controls_enable_ebs_encryption_by_default, true)
  security_controls_ebs_encryption_enabled           = try(each.value.security_controls_ebs_encryption_enabled, var.defaults.security_controls_ebs_encryption_enabled, true)
  security_controls_ebs_kms_key_arn                  = try(each.value.security_controls_ebs_kms_key_arn, var.defaults.security_controls_ebs_kms_key_arn, null)
  security_controls_create_ebs_kms_key               = try(each.value.security_controls_create_ebs_kms_key, var.defaults.security_controls_create_ebs_kms_key, false)
  security_controls_ebs_kms_key_deletion_window      = try(each.value.security_controls_ebs_kms_key_deletion_window, var.defaults.security_controls_ebs_kms_key_deletion_window, 7)
  security_controls_ebs_kms_key_rotation             = try(each.value.security_controls_ebs_kms_key_rotation, var.defaults.security_controls_ebs_kms_key_rotation, true)
  security_controls_ebs_kms_key_alias                = try(each.value.security_controls_ebs_kms_key_alias, var.defaults.security_controls_ebs_kms_key_alias, "alias/cis-hardening-ebs-encryption")

  # IAM Password Policy Module Variables - Password Policy
  iam_password_policy_create                         = try(each.value.iam_password_policy_create, var.defaults.iam_password_policy_create, true)
  iam_password_policy_minimum_password_length        = try(each.value.iam_password_policy_minimum_password_length, var.defaults.iam_password_policy_minimum_password_length, 14)
  iam_password_policy_require_lowercase_characters   = try(each.value.iam_password_policy_require_lowercase_characters, var.defaults.iam_password_policy_require_lowercase_characters, true)
  iam_password_policy_require_numbers                = try(each.value.iam_password_policy_require_numbers, var.defaults.iam_password_policy_require_numbers, true)
  iam_password_policy_require_uppercase_characters   = try(each.value.iam_password_policy_require_uppercase_characters, var.defaults.iam_password_policy_require_uppercase_characters, true)
  iam_password_policy_require_symbols                = try(each.value.iam_password_policy_require_symbols, var.defaults.iam_password_policy_require_symbols, true)
  iam_password_policy_allow_users_to_change_password = try(each.value.iam_password_policy_allow_users_to_change_password, var.defaults.iam_password_policy_allow_users_to_change_password, true)
  iam_password_policy_hard_expiry                    = try(each.value.iam_password_policy_hard_expiry, var.defaults.iam_password_policy_hard_expiry, false)
  iam_password_policy_max_password_age               = try(each.value.iam_password_policy_max_password_age, var.defaults.iam_password_policy_max_password_age, 90)
  iam_password_policy_password_reuse_prevention      = try(each.value.iam_password_policy_password_reuse_prevention, var.defaults.iam_password_policy_password_reuse_prevention, 24)

  # IAM Password Policy Module Variables - AWS Support Role (IAM.18)
  iam_password_policy_create_aws_support_role               = try(each.value.iam_password_policy_create_aws_support_role, var.defaults.iam_password_policy_create_aws_support_role, true)
  iam_password_policy_aws_support_role_name                 = try(each.value.iam_password_policy_aws_support_role_name, var.defaults.iam_password_policy_aws_support_role_name, "AWSSupport-IncidentManagement")
  iam_password_policy_aws_support_role_path                 = try(each.value.iam_password_policy_aws_support_role_path, var.defaults.iam_password_policy_aws_support_role_path, "/")
  iam_password_policy_aws_support_role_max_session_duration = try(each.value.iam_password_policy_aws_support_role_max_session_duration, var.defaults.iam_password_policy_aws_support_role_max_session_duration, 3600)
  iam_password_policy_aws_support_role_trusted_entities     = try(each.value.iam_password_policy_aws_support_role_trusted_entities, var.defaults.iam_password_policy_aws_support_role_trusted_entities, [])
  iam_password_policy_aws_support_role_require_mfa          = try(each.value.iam_password_policy_aws_support_role_require_mfa, var.defaults.iam_password_policy_aws_support_role_require_mfa, true)
  iam_password_policy_aws_support_role_tags                 = try(each.value.iam_password_policy_aws_support_role_tags, var.defaults.iam_password_policy_aws_support_role_tags, {})
}
