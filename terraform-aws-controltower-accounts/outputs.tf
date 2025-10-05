output "provisioned_product_ids" {
  description = "A map of provisioned product IDs keyed by account name."
  value       = { for k, v in aws_servicecatalog_provisioned_product.account : k => v.id }
}

output "provisioned_product_arns" {
  description = "A map of provisioned product ARNs keyed by account name."
  value       = { for k, v in aws_servicecatalog_provisioned_product.account : k => v.arn }
}

output "provisioned_product_statuses" {
  description = "A map of provisioned product statuses keyed by account name."
  value       = { for k, v in aws_servicecatalog_provisioned_product.account : k => v.status }
}

output "provisioned_product_outputs" {
  description = "A map of outputs from the provisioned products keyed by account name. Each output map might include the AccountId if the underlying CloudFormation stack outputs it."
  value       = { for k, v in aws_servicecatalog_provisioned_product.account : k => v.outputs }
}

# Note: Extracting the newly created Account IDs directly from the aws_servicecatalog_provisioned_product
# resources can be tricky as it depends on the underlying CloudFormation stack outputting it with a known key.
# The 'outputs' attribute above will contain all stack outputs.
# You might need to inspect its contents to find the AccountId.
# Example of how you might try to get them if the output key is 'AccountId':
#
output "account_ids" {
  description = "Map of account names to their AWS Account IDs, extracted from product outputs."
  value = {
    for acc_key, acc_product in aws_servicecatalog_provisioned_product.account : acc_key => try(
      ([for output_item in acc_product.outputs : output_item.value if output_item.key == "AccountId"])[0],
      null # Value if AccountId output is not found or the list is empty
    )
  }
}
