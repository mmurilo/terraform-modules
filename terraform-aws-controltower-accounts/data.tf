data "aws_ssoadmin_instances" "this" {}

locals {
  # Get the first (and usually only) SSO instance
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  # Check if any accounts have group assignments
  has_group_assignments = anytrue([
    for account in var.accounts : length(account.sso_group_assignments) > 0
  ])
}
