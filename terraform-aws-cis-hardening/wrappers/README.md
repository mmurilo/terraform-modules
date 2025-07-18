# AWS CIS Hardening Terraform Module Wrapper

This wrapper module simplifies the deployment of the AWS CIS Hardening Terraform module across multiple configurations or environments. It allows you to create multiple instances of the CIS hardening module with different configurations using a single module call.

## Features

The wrapper enables:
- **Multiple Environment Deployment**: Deploy CIS hardening across dev, staging, production with different configurations
- **Multi-Account Deployment**: Configure different settings for different AWS accounts
- **Multi-Region Deployment**: Deploy the same configurations across multiple regions
- **DRY Principle**: Reduce code duplication by defining common defaults once
- **Flexible Configuration**: Override any module variable on a per-instance basis

## Security Controls Included

This wrapper deploys all the security controls from the parent module:

- ✅ **IAM Access Analyzer** (Account and Organization level)
- ✅ **IAM Password Policy** (CIS 1.9, 1.10)
- ✅ **Security Controls** (SecurityHub S3.1, EC2.7)

## Usage

### Basic Usage

```hcl
module "cis_hardening_wrapper" {
  source = "./path/to/cis-hardening/wrappers"

  defaults = {
    tags = {
      ManagedBy = "terraform"
      Project   = "security-hardening"
    }
  }

  items = {
    production = {
      iam_access_analyzer_type = "ORGANIZATION"
      tags = {
        Environment = "production"
        account     = "security"
      }
    }
    
    staging = {
      iam_access_analyzer_type = "ACCOUNT"
      tags = {
        Environment = "staging"
        account     = "staging"
      }
    }
  }
}
```

### Multi-Account Example

```hcl
module "cis_hardening_multi_account" {
  source = "./path/to/cis-hardening/wrappers"

  # Common defaults for all accounts
  defaults = {
    # Security controls
    security_controls_enable_s3_account_public_access_block = true
    security_controls_enable_ebs_encryption_by_default     = true
    security_controls_create_ebs_kms_key                   = true
    
    # Common tags
    tags = {
      ManagedBy = "terraform"
      account   = "management"
    }
  }

  items = {
    # Production account hardening
    production = {
      # Strict password policy for production
      iam_password_policy_minimum_password_length      = 20
      iam_password_policy_password_reuse_prevention    = 24
      iam_password_policy_max_password_age             = 30
      iam_password_policy_hard_expiry                  = true
      
      # Organization-level access analyzer
      iam_access_analyzer_type = "ORGANIZATION"
      
      tags = {
        Environment = "production"
        purpose     = "production-security-compliance"
      }
    }
    
    # Staging account hardening
    staging = {
      # Relaxed settings for staging
      iam_password_policy_minimum_password_length   = 14
      iam_password_policy_password_reuse_prevention = 5
      iam_password_policy_max_password_age          = 90
      iam_password_policy_hard_expiry               = false
      
      # Account-level access analyzer
      iam_access_analyzer_type = "ACCOUNT"
      
      tags = {
        Environment = "staging"
        purpose     = "staging-security-testing"
      }
    }
    
    # Development account hardening
    development = {
      # Basic password policy for dev
      iam_password_policy_minimum_password_length = 12
      iam_password_policy_max_password_age        = 180
      
      tags = {
        Environment = "development"
        purpose     = "development-security-baseline"
      }
    }
  }
}
```

### Multi-Region Deployment Example

```hcl
# Deploy across multiple regions with region-specific configurations
module "cis_hardening_multi_region" {
  source = "./path/to/cis-hardening/wrappers"

  defaults = {
    # S3 settings (account-wide)
    security_controls_enable_s3_account_public_access_block = true
    
    # EBS encryption (region-specific)
    security_controls_enable_ebs_encryption_by_default = true
    security_controls_create_ebs_kms_key               = true
    
    tags = {
      ManagedBy = "terraform"
      Project   = "multi-region-security"
    }
  }

  items = {
    us_east_1 = {
      security_controls_ebs_kms_key_alias = "alias/ebs-encryption-us-east-1"
      
      tags = {
        Region = "us-east-1"
        Role   = "primary"
      }
    }
    
    us_west_2 = {
      security_controls_ebs_kms_key_alias = "alias/ebs-encryption-us-west-2"
      
      tags = {
        Region = "us-west-2"
        Role   = "secondary"
      }
    }
    
    eu_west_1 = {
      security_controls_ebs_kms_key_alias = "alias/ebs-encryption-eu-west-1"
      
      tags = {
        Region     = "eu-west-1"
        Role       = "eu-compliance"
        Compliance = "GDPR"
      }
    }
  }
}
```

### Selective Module Deployment

```hcl
# Deploy only specific security controls per environment
module "cis_hardening_selective" {
  source = "./path/to/cis-hardening/wrappers"

  defaults = {
    tags = {
      ManagedBy = "terraform"
    }
  }

  items = {
    # Password policy only for development
    development_password_policy = {
      create_iam_access_analyzer = false
      create_iam_password_policy = true
      create_security_controls   = false
      
      iam_password_policy_minimum_password_length = 12
      
      tags = {
        Environment = "development"
        Purpose     = "iam-security"
      }
    }
    
    # Full security controls for compliance account
    compliance_full = {
      create_iam_access_analyzer = true
      create_iam_password_policy = true
      create_security_controls   = true
      
      # Organization-level IAM Access Analyzer
      iam_access_analyzer_type = "ORGANIZATION"
      
      # Strict security controls
      security_controls_create_ebs_kms_key = true
      
      tags = {
        Environment = "compliance"
        Purpose     = "full-security-hardening"
      }
    }
    
    # S3 security controls only for data accounts
    data_account_s3 = {
      create_iam_access_analyzer = false
      create_iam_password_policy = false
      create_security_controls   = true
      
      # Only enable S3 controls
      security_controls_enable_ebs_encryption_by_default = false
      
      tags = {
        Environment = "data"
        Purpose     = "s3-security"
      }
    }
  }
}
```

## Configuration

### Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `defaults` | Map of default values applied to all items | `any` | `{}` |
| `items` | Map of items to create, each with custom configuration | `any` | `{}` |

### Outputs

| Output | Description |
|--------|-------------|
| `wrapper` | Map of all module outputs for each item |

## Variable Inheritance

The wrapper uses a three-level priority system:

1. **Item-specific values** (highest priority)
2. **Default values** from `var.defaults`
3. **Module defaults** (lowest priority)

This is implemented using Terraform's `try()` function:
```hcl
iam_password_policy_minimum_password_length = try(each.value.iam_password_policy_minimum_password_length, var.defaults.iam_password_policy_minimum_password_length, 14)
```

## Available Configuration Options

All variables from the parent CIS hardening module are available:

### General Configuration
- `tags` - Resource tags
- Module control flags (`create_*`)

### IAM Access Analyzer Configuration
- Analyzer type and name
- Archive rules
- Unused access configuration

### IAM Password Policy Configuration
- Password requirements
- Character complexity
- Expiration and reuse settings

### Security Controls Configuration
- S3 public access blocking
- EBS default encryption

## Best Practices

1. **Use Descriptive Keys**: Use meaningful names for items (e.g., "production", "staging")
2. **Leverage Defaults**: Put common configuration in `defaults` to reduce duplication
3. **Environment-Specific Settings**: Customize security settings per environment
4. **Resource Naming**: Use consistent naming patterns across environments
5. **Tag Strategy**: Implement consistent tagging for resource management

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| random | >= 3.4 |

## License

This wrapper follows the same license as the parent CIS hardening module.

## Contributing

When contributing to this wrapper:
1. Ensure all parent module variables are included in `main.tf`
2. Follow the `try()` pattern for variable inheritance
3. Update examples in this README
4. Test with multiple item configurations 
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_wrapper"></a> [wrapper](#module\_wrapper) | ../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_defaults"></a> [defaults](#input\_defaults) | Map of default values which will be used for each item. | `any` | `{}` | no |
| <a name="input_items"></a> [items](#input\_items) | Map of items to create a wrapper over. Values are passed through to the module. | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_wrapper"></a> [wrapper](#output\_wrapper) | Map of outputs of a wrapper. |
<!-- END_TF_DOCS -->