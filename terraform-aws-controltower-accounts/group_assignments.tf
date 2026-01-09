# This file contains resources for assigning IAM Identity Center groups to accounts

# Lookup for Identity Store groups by display name
data "aws_identitystore_group" "this" {
  for_each = local.has_group_assignments ? toset(flatten([
    for account_key, account in var.accounts : [
      for group_name, _ in account.sso_group_assignments : group_name
    ]
  ])) : []

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.key
    }
  }
}

# Lookup for permission sets by name
data "aws_ssoadmin_permission_set" "this" {
  for_each = local.has_group_assignments ? toset(flatten([
    for account_key, account in var.accounts : [
      for _, permission_sets in account.sso_group_assignments : permission_sets
    ]
  ])) : []

  instance_arn = local.sso_instance_arn
  name         = each.key
}

# Create account assignments for each group and permission set
resource "aws_ssoadmin_account_assignment" "group_assignments" {
  for_each = local.has_group_assignments ? {
    for idx, assignment in flatten([
      for account_key, account in var.accounts : [
        for group_name, permission_sets in account.sso_group_assignments : [
          for permission_set in permission_sets : {
            account_key    = account_key
            group_name     = group_name
            permission_set = permission_set
            key            = "${account_key}-${group_name}-${permission_set}"
          }
        ]
      ]
    ]) : assignment.key => assignment
  } : {}

  instance_arn       = local.sso_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  principal_id   = data.aws_identitystore_group.this[each.value.group_name].group_id
  principal_type = "GROUP"

  target_id = (
    lookup(var.accounts[each.value.account_key], "AccountId", null) != null ?
    var.accounts[each.value.account_key].AccountId :
    try([for output in aws_servicecatalog_provisioned_product.account[each.value.account_key].outputs : output.value if output.key == "AccountId"][0], "")
  )
  target_type = "AWS_ACCOUNT"

  depends_on = [aws_servicecatalog_provisioned_product.account]
}
