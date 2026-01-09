locals {
  # Create a map of account parameters with SSO user fallbacks applied
  account_parameters = {
    for account_key, account in var.accounts : account_key => merge(
      # Start with all original account parameters except sso_group_assignments
      {
        for k, v in account : k => v if k != "sso_group_assignments"
      },
      # Add SSO parameters with fallbacks
      {
        SSOUserEmail     = account.SSOUserEmail != null ? account.SSOUserEmail : var.default_SSOUserEmail
        SSOUserFirstName = account.SSOUserFirstName != null ? account.SSOUserFirstName : var.default_SSOUserFirstName
        SSOUserLastName  = account.SSOUserLastName != null ? account.SSOUserLastName : var.default_SSOUserLastName
      }
    )
  }
}

resource "aws_servicecatalog_provisioned_product" "account" {
  for_each = var.accounts

  name = each.key

  product_name               = var.product_name
  provisioning_artifact_name = var.provisioning_artifact_name
  product_id                 = var.product_name == null ? var.product_id : null
  provisioning_artifact_id   = var.provisioning_artifact_name == null ? var.provisioning_artifact_id : null

  # Use a single dynamic block for all parameters to preserve their order in the Terraform state
  dynamic "provisioning_parameters" {
    for_each = {
      for k, v in local.account_parameters[each.key] : k => v
      if k != "sso_group_assignments" && k != "AccountId"
    }

    content {
      key   = provisioning_parameters.key
      value = provisioning_parameters.value
    }
  }

  accept_language = "en"

  tags = var.tags

  # Prevent tag updates which cause errors in AWS Service Catalog
  lifecycle {
    ignore_changes = [
      tags,
      tags_all,
    ]
  }
}
