# AWS Control Tower Account Factory Terraform Module

This Terraform module provisions one or multiple AWS accounts using the AWS Control Tower Account Factory, which is exposed as an AWS Service Catalog product.

## Usage

This module provisions multiple `aws_servicecatalog_provisioned_product` resources, targeting the \"AWS Control Tower Account Factory\" product.

```hcl
module "aws_accounts" {
  source = "./control-tower-account-factory" # Or path to this module

  provisioning_artifact_name = "v1.20" # Replace with the actual active version of your Account Factory product

  # Default SSO user values to use when accounts don't specify their own
  default_SSOUserEmail     = "default-admin@example.com"
  default_SSOUserFirstName = "DefaultAdmin"
  default_SSOUserLastName  = "User"

  accounts = {
    "Account-1" = {
      AccountName               = "MyDevAccount"
      AccountEmail              = "unique-email+dev-account@example.com"
      ManagedOrganizationalUnit = "Sandbox (ou-xxxx-xxxxxxxx)" # e.g., "OUName (ou-identifier)"
      SSOUserEmail              = "sso-user@example.com"
      SSOUserFirstName          = "SSOUser"
      SSOUserLastName           = "Example"
      
      # Optional: Assign IAM Identity Center groups to this account
      sso_group_assignments = {
        "DevOpsTeam" = ["PowerUserAccess", "ReadOnlyAccess"]
        "SecurityTeam" = ["SecurityAudit"]
      }
      
      # Add any other Account Factory parameters as needed
    },
    "Account-2" = {
      AccountName               = "MyProdAccount"
      AccountEmail              = "unique-email+prod-account@example.com"
      ManagedOrganizationalUnit = "Production (ou-yyyy-yyyyyyyy)"
      # SSO user values will use the default values since they're not specified here
      
      # Optional: Assign IAM Identity Center groups to this account
      sso_group_assignments = {
        "AdminTeam" = ["AdministratorAccess"],
        "DevOpsTeam" = ["PowerUserAccess"]
      }
      
      # Add any other Account Factory parameters as needed
    }
    # Add more accounts as needed
  }

  tags = {
    Environment = "Mixed"
    CostCenter  = "12345"
    Project     = "AccountProvisioning"
  }
}

# Access outputs for specific accounts
output "dev_account_outputs" {
  value = module.aws_accounts.provisioned_product_outputs["Account-1"]
}
```

## Important Considerations

:warning:

* The User or role running this Terraform module must have the necessary permissions to provision products in AWS Service Catalog and create accounts in AWS Organizations.
  * The User or Role must also be associate with the AWS Control Tower Account Factory Portfolio in Service Catalog
  * This access can be enabled using the Access Tab in the wAWS Console or `aws_servicecatalog_principal_portfolio_association` Terraform [resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicecatalog_principal_portfolio_association).

* **Account Factory Product Name and Version**:
  * The module uses `product_name = "AWS Control Tower Account Factory"`. Verify this is the exact name of the Account Factory product in your AWS Service Catalog.
  * You **must** specify the `provisioning_artifact_name` (e.g., `v1.0`, `v1.2.3`). You can find available versions in the AWS Service Catalog console for the "AWS Control Tower Account Factory" product. Using an incorrect version will cause provisioning to fail.
  * Alternatively, you can use `product_id` and `provisioning_artifact_id` if you know these specific identifiers.
* **Map Keys**: The keys of the `accounts` map will be used to name the provisioned products (with "-pp" suffix) and to index the module's outputs.
* **Parameter Names**: The module uses the exact parameter names expected by AWS Control Tower Account Factory (`AccountName`, `AccountEmail`, `ManagedOrganizationalUnit`, etc.). Do not change these keys as they must match what the Service Catalog product expects.
* **Organizational Unit (OU)**: The `ManagedOrganizationalUnit` for each account must be provided in the format `DisplayName (ou-xxxxxxxx)`. You can find this in your AWS Organizations console or via the AWS CLI.
* **Account Email Uniqueness**: The `AccountEmail` provided for each account must be globally unique and not associated with any other AWS account.
* **Provisioning Time**: Provisioning a new account via Account Factory can take a significant amount of time (often 20-60 minutes or more). When provisioning multiple accounts, they will be created in parallel.
* **Additional Parameters**: You can add any additional parameters your specific Account Factory product version requires. Simply add them to the account map with the correct parameter key name.
* **Outputs**: The module outputs maps containing information about each provisioned product, keyed by the account map keys. The `provisioned_product_outputs` output map may contain the `AccountId` of the newly created accounts, but this depends on the Account Factory product's CloudFormation template.

### IAM Identity Center Group Assignments

The module can assign IAM Identity Center (formerly AWS SSO) groups to the newly created accounts. This is done via the optional `sso_group_assignments` attribute for each account:

* For each account, you specify a map of group names to permission sets
* Each group can be assigned multiple permission sets for an account

**Requirements for IAM Identity Center Group Assignments**:

* The IAM Identity Center instance must be already configured in the AWS Organization
* Permission sets must already exist in IAM Identity Center
* Groups must already exist in IAM Identity Center
* The AWS provider must have access to the IAM Identity Center instance

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_servicecatalog_provisioned_product.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicecatalog_provisioned_product) | resource |
| [aws_ssoadmin_account_assignment.group_assignments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [aws_ssoadmin_permission_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_permission_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | A map of accounts to be provisioned. Each account requires parameters matching those expected by the Account Factory product. | <pre>map(object({<br/>    # Required Account Factory parameters<br/>    AccountName               = string<br/>    AccountEmail              = string<br/>    ManagedOrganizationalUnit = string<br/>    SSOUserEmail              = optional(string)<br/>    SSOUserFirstName          = optional(string)<br/>    SSOUserLastName           = optional(string)<br/>    AccountId                 = optional(string)<br/><br/>    # Optional IAM Identity Center group assignments<br/>    sso_group_assignments = optional(map(list(string)), {})<br/><br/>    # Additional optional Account Factory parameters<br/>    # These will be passed through to the provisioning product<br/>  }))</pre> | n/a | yes |
| <a name="input_default_SSOUserEmail"></a> [default\_SSOUserEmail](#input\_default\_SSOUserEmail) | Default SSO user email to use when an account doesn't specify one | `string` | `null` | no |
| <a name="input_default_SSOUserFirstName"></a> [default\_SSOUserFirstName](#input\_default\_SSOUserFirstName) | Default SSO user first name to use when an account doesn't specify one | `string` | `null` | no |
| <a name="input_default_SSOUserLastName"></a> [default\_SSOUserLastName](#input\_default\_SSOUserLastName) | Default SSO user last name to use when an account doesn't specify one | `string` | `null` | no |
| <a name="input_product_id"></a> [product\_id](#input\_product\_id) | The ID of the AWS Service Catalog product. | `string` | `null` | no |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | The name of the AWS Service Catalog product. | `string` | `"AWS Control Tower Account Factory"` | no |
| <a name="input_provisioning_artifact_id"></a> [provisioning\_artifact\_id](#input\_provisioning\_artifact\_id) | The ID of the AWS Service Catalog provisioning artifact. | `string` | `null` | no |
| <a name="input_provisioning_artifact_name"></a> [provisioning\_artifact\_name](#input\_provisioning\_artifact\_name) | The name of the provisioning artifact (e.g., product version) for the Account Factory. Example: "v1.2.3". | `string` | `"AWS Control Tower Account Factory"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to apply to the provisioned products. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_ids"></a> [account\_ids](#output\_account\_ids) | Map of account names to their AWS Account IDs, extracted from product outputs. |
| <a name="output_provisioned_product_arns"></a> [provisioned\_product\_arns](#output\_provisioned\_product\_arns) | A map of provisioned product ARNs keyed by account name. |
| <a name="output_provisioned_product_ids"></a> [provisioned\_product\_ids](#output\_provisioned\_product\_ids) | A map of provisioned product IDs keyed by account name. |
| <a name="output_provisioned_product_outputs"></a> [provisioned\_product\_outputs](#output\_provisioned\_product\_outputs) | A map of outputs from the provisioned products keyed by account name. Each output map might include the AccountId if the underlying CloudFormation stack outputs it. |
| <a name="output_provisioned_product_statuses"></a> [provisioned\_product\_statuses](#output\_provisioned\_product\_statuses) | A map of provisioned product statuses keyed by account name. |
<!-- END_TF_DOCS -->