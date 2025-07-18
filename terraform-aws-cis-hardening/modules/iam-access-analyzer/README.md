# AWS IAM Access Analyzer Terraform Module

This Terraform module creates AWS IAM Access Analyzer resources including external access analyzers, unused access analyzers, and archive rules.

## Features

- **External Access Analyzer**: Identifies resources shared with external entities
- **Unused Access Analyzer**: Identifies unused access in IAM roles and users (paid feature)
- **Archive Rules**: Automatically archive findings that match specific criteria
- **Organization Support**: Can be configured at account or organization level
- **Multi-Region Support**: Deploy in multiple regions for comprehensive coverage

## Usage

### Basic External Access Analyzer (Account Level)

```hcl
module "iam_access_analyzer" {
  source = "./terraform-aws-iam-access-analyzer"

  analyzer_name = "MyAccountAnalyzer"
  type          = "ACCOUNT"

  tags = {
    Environment = "production"
    Owner       = "security-team"
  }
}
```

### Organization External Access Analyzer

```hcl
module "iam_access_analyzer_org" {
  source = "./terraform-aws-iam-access-analyzer"

  analyzer_name = "MyOrgExternalAnalyzer"
  type          = "ORGANIZATION"

  tags = {
    Environment = "production"
    Owner       = "security-team"
  }
}
```

### Organization Unused Access Analyzer

```hcl
module "iam_access_analyzer_unused" {
  source = "./terraform-aws-iam-access-analyzer"

  analyzer_name = "MyOrgUnusedAnalyzer"
  type          = "ORGANIZATION_UNUSED_ACCESS"

  unused_access_configuration = {
    unused_access_age = 90  # Days
  }

  tags = {
    Environment = "production"
    Owner       = "security-team"
  }
}
```

### Complete Example with Archive Rules

```hcl
module "iam_access_analyzer_complete" {
  source = "./terraform-aws-iam-access-analyzer"

  analyzer_name = "CompleteAnalyzer"
  type          = "ORGANIZATION"

  # Archive rules to automatically handle specific findings
  archive_rules = {
    "ArchivePublicS3Buckets" = {
      filters = [
        {
          criteria = "resourceType"
          eq       = ["AWS::S3::Bucket"]
        },
        {
          criteria = "isPublic"
          eq       = ["true"]
        }
      ]
    }
    "ArchiveCrossAccountIAMRoles" = {
      filters = [
        {
          criteria = "resourceType"
          eq       = ["AWS::IAM::Role"]
        },
        {
          criteria = "principal.AWS"
          contains = ["arn:aws:iam::123456789012:root"]
        }
      ]
    }
  }

  tags = {
    Environment = "production"
    Owner       = "security-team"
  }
}
```

### Multi-Region Deployment

Since IAM Access Analyzer is a regional service, you should create analyzers in each region:

```hcl
# Primary region
module "iam_access_analyzer_us_east_1" {
  source = "./terraform-aws-iam-access-analyzer"

  providers = {
    aws = aws.us_east_1
  }

  analyzer_name = "OrgAnalyzer-us-east-1"
  type          = "ORGANIZATION"

  tags = {
    Environment = "production"
    Region      = "us-east-1"
  }
}

# Secondary region
module "iam_access_analyzer_us_west_2" {
  source = "./terraform-aws-iam-access-analyzer"

  providers = {
    aws = aws.us_west_2
  }

  analyzer_name = "OrgAnalyzer-us-west-2"
  type          = "ORGANIZATION"

  tags = {
    Environment = "production"
    Region      = "us-west-2"
  }
}
```

## Important Considerations

### Prerequisites

1. **Organization Analyzer**: Must be run from the AWS Organizations management account or a delegated administrator account
2. **Permissions**: Ensure the executing role has the following permissions:
   - `access-analyzer:CreateAnalyzer`
   - `access-analyzer:TagResource`
   - `access-analyzer:CreateArchiveRule`
   - For organization analyzers: `organizations:ListAccounts`, `organizations:DescribeOrganization`

### Delegated Administrator Setup

If you want to manage IAM Access Analyzer from a delegated administrator account:

```hcl
# Run this from the management account
resource "aws_organizations_delegated_administrator" "access_analyzer" {
  account_id        = "123456789012"  # Delegated admin account ID
  service_principal = "access-analyzer.amazonaws.com"
}

# Then run the analyzer module from the delegated admin account
module "iam_access_analyzer" {
  source = "./terraform-aws-iam-access-analyzer"

  type = "ORGANIZATION"
  # ... other configuration

  depends_on = [aws_organizations_delegated_administrator.access_analyzer]
}
```

### Cost Considerations

- **External Access Analysis**: Free
- **Unused Access Analysis**: Charged based on number of IAM roles and users analyzed per month
- **Archive Rules**: No additional cost

### Regional Deployment Strategy

For external access analysis:
- Deploy in all regions where you have resources
- Each region requires a separate analyzer

For unused access analysis:
- Since IAM is global, deploying in one region is sufficient
- Additional regions will increase costs without added value

## Archive Rule Filter Criteria

Common filter criteria for archive rules:

| Criteria | Description | Example Values |
|----------|-------------|----------------|
| `resourceType` | Type of AWS resource | `AWS::S3::Bucket`, `AWS::IAM::Role` |
| `isPublic` | Whether resource is publicly accessible | `true`, `false` |
| `principal.AWS` | AWS principal with access | `arn:aws:iam::123456789012:root` |
| `principal.Service` | AWS service with access | `lambda.amazonaws.com` |
| `condition.StringEquals` | Condition key-value pairs | Various |
| `action` | Actions granted | `s3:GetObject`, `iam:AssumeRole` |

## Troubleshooting

### Common Issues

1. **Organization analyzer fails**: Ensure you're running from management account or delegated admin
2. **No findings generated**: Check that resources exist and analyzer is in correct region
3. **Archive rules not working**: Verify filter criteria match your finding structure

### Useful Commands

```bash
# List analyzers
aws accessanalyzer list-analyzers

# Get analyzer details
aws accessanalyzer get-analyzer --analyzer-name <analyzer-name>

# List findings
aws accessanalyzer list-findings --analyzer-arn <analyzer-arn>

# Trigger manual scan
aws accessanalyzer start-resource-scan --analyzer-arn <analyzer-arn> --resource-arn <resource-arn>
```

## Examples

See the `examples/` directory for complete working examples.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_accessanalyzer_analyzer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |
| [aws_accessanalyzer_archive_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_archive_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_analyzer | Controls if IAM Access Analyzer should be created | `bool` | `true` | no |
| analyzer_name | Name of the analyzer. If not provided, a default name will be used based on analyzer type | `string` | `null` | no |
| type | Type of analyzer. Valid values are ACCOUNT, ORGANIZATION, ORGANIZATION_UNUSED_ACCESS | `string` | `"ACCOUNT"` | no |
| unused_access_configuration | Configuration for unused access analyzer. Only applicable when type is ORGANIZATION_UNUSED_ACCESS | `object({unused_access_age = number})` | `null` | no |
| archive_rules | Map of archive rules to create for the analyzer | `map(object({filters = list(object({criteria = string, contains = optional(list(string)), eq = optional(list(string)), exists = optional(string), neq = optional(list(string))}))})` | `{}` | no |
| tags | A map of tags to assign to the analyzer | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| analyzer_arn | ARN of the IAM Access Analyzer |
| analyzer_id | ID of the IAM Access Analyzer |
| analyzer_name | Name of the IAM Access Analyzer |
| analyzer_type | Type of the IAM Access Analyzer |
| archive_rules | Map of archive rules created |

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/LICENSE) for full details. 
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_accessanalyzer_analyzer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |
| [aws_accessanalyzer_archive_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_archive_rule) | resource |
| [random_string.analyzer_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_analyzer_name"></a> [analyzer\_name](#input\_analyzer\_name) | Name of the analyzer. If not provided, a default name will be used based on analyzer type | `string` | `null` | no |
| <a name="input_archive_rules"></a> [archive\_rules](#input\_archive\_rules) | Map of archive rules to create for the analyzer | <pre>map(object({<br/>    filters = list(object({<br/>      criteria = string<br/>      contains = optional(list(string))<br/>      eq       = optional(list(string))<br/>      exists   = optional(string)<br/>      neq      = optional(list(string))<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_create_analyzer"></a> [create\_analyzer](#input\_create\_analyzer) | Controls if IAM Access Analyzer should be created | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the analyzer | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | Type of analyzer. Valid values are ACCOUNT, ORGANIZATION, ORGANIZATION\_UNUSED\_ACCESS | `string` | `"ACCOUNT"` | no |
| <a name="input_unused_access_configuration"></a> [unused\_access\_configuration](#input\_unused\_access\_configuration) | Configuration for unused access analyzer. Only applicable when type is ORGANIZATION\_UNUSED\_ACCESS | <pre>object({<br/>    unused_access_age = number<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_analyzer_arn"></a> [analyzer\_arn](#output\_analyzer\_arn) | ARN of the IAM Access Analyzer |
| <a name="output_analyzer_id"></a> [analyzer\_id](#output\_analyzer\_id) | ID of the IAM Access Analyzer |
| <a name="output_analyzer_name"></a> [analyzer\_name](#output\_analyzer\_name) | Name of the IAM Access Analyzer |
| <a name="output_analyzer_type"></a> [analyzer\_type](#output\_analyzer\_type) | Type of the IAM Access Analyzer |
| <a name="output_archive_rules"></a> [archive\_rules](#output\_archive\_rules) | Map of archive rules created |
<!-- END_TF_DOCS -->