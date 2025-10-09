# Control Tower CloudTrail S3 Logging Example

This example demonstrates how to deploy the CloudTrail S3 logging module in an AWS Control Tower environment with proper cross-account configuration.

## Architecture

```
Management Account (Deploy Here)    →    Log Archive Account
├── CloudTrail (Organization Trail)      ├── S3 Bucket (CloudTrail Logs)
├── CloudWatch Logs (Optional)           ├── Bucket Policy (Cross-Account)
└── IAM Roles (CloudWatch)               └── Lifecycle Configuration
```

## Prerequisites

1. **AWS Control Tower** environment with:
   - Management Account (where you deploy this)
   - Log Archive Account (where S3 bucket will be created)

2. **Cross-Account Role** in Log Archive Account with S3 permissions:
   - `OrganizationAccountAccessRole` (default Control Tower role)
   - `AWSControlTowerExecution` (enhanced permissions)
   - Custom role with S3 permissions

3. **Terraform** >= 1.0 with AWS provider >= 5.0

## Usage

### Step 1: Set Variables

Create a `terraform.tfvars` file:

```hcl
# Required
log_archive_account_id = "123456789012"  # Your Log Archive Account ID

# Optional customization
aws_region               = "us-east-1"
trail_name              = "my-org-s3-data-events"
s3_bucket_prefix        = "my-org-cloudtrail"
cross_account_role_name = "OrganizationAccountAccessRole"
environment             = "production"

# KMS encryption configuration (enabled by default)
create_kms_key           = true
kms_key_alias           = "control-tower-cloudtrail-encryption"
kms_key_rotation        = true
kms_key_deletion_window = 30

# Lifecycle management
log_retention_days = 2555  # ~7 years (null for indefinite)

# Optional CloudWatch Logs
enable_cloudwatch_logs    = true
cloudwatch_retention_days = 90
```

### Step 2: Deploy from Management Account

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Deploy the module
terraform apply
```

### Step 3: Verify Deployment

```bash
# Check outputs
terraform output

# Verify CloudTrail is logging
aws cloudtrail describe-trails --trail-name-list $(terraform output -raw cloudtrail_name)

# Check S3 bucket (if you have access to Log Archive Account)
aws s3 ls s3://$(terraform output -raw s3_bucket_name)
```

## What Gets Created

### In Management Account:
- **CloudTrail** organization trail with S3 data event logging
- **KMS Key** with proper CloudTrail policies for encryption
- **KMS Key Alias** for easy identification
- **CloudWatch Log Group** (if enabled) for real-time monitoring
- **IAM Role** for CloudWatch Logs delivery

### In Log Archive Account:
- **S3 Bucket** with secure configuration:
  - KMS encryption using Management Account key
  - Versioning enabled
  - Public access blocked
  - Lifecycle policies for cost optimization
- **Bucket Policy** allowing CloudTrail cross-account writes
- **SSO Administrator Access** automatically configured for log decryption

## Cost Optimization

The module includes automatic cost optimization:

1. **S3 Lifecycle Transitions**:
   - Day 0-29: Standard storage
   - Day 30-89: Standard-IA
   - Day 90-364: Glacier
   - Day 365+: Deep Archive

2. **Log Retention** (optional):
   - Automatic deletion after specified days
   - Default: 7 years (2555 days)

3. **CloudWatch Logs**:
   - Optional (disabled by default)
   - Configurable retention period

## SecurityHub Compliance

This deployment addresses:
- **[S3.22]** S3 buckets should log object-level write events
- **[S3.23]** S3 buckets should log object-level read events

The CloudTrail is configured with advanced event selectors to capture both read and write S3 data events across all organization accounts.

## Troubleshooting

### Common Issues

1. **Permission Denied for Log Archive Account**
   ```
   Error: AccessDenied: User ... is not authorized to perform: s3:CreateBucket
   ```
   **Solution**: Verify the cross-account role exists and has S3 permissions.

2. **CloudTrail Already Exists**
   ```
   Error: Trail ... already exists
   ```
   **Solution**: Use a different `trail_name` or import existing trail.

3. **Organization Trail Permission Error**
   ```
   Error: User ... is not authorized to call organizations:DescribeOrganization
   ```
   **Solution**: Ensure deployment is from the Management Account with organization permissions.

4. **SSO Administrators Cannot Decrypt Logs**
   ```
   Error: Access Denied when downloading CloudTrail logs from S3
   ```
   **Solution**: Check that SSO Administrator roles exist in Log Archive Account with pattern `AWSReservedSSO_AWSAdministratorAccess_*`.

### Useful Commands

```bash
# Check current account
aws sts get-caller-identity

# Verify Control Tower setup
aws organizations describe-organization

# Test cross-account role assumption
aws sts assume-role \
  --role-arn "arn:aws:iam::${LOG_ARCHIVE_ACCOUNT_ID}:role/OrganizationAccountAccessRole" \
  --role-session-name "test-session"

# Check CloudTrail status
aws cloudtrail get-trail-status --name $(terraform output -raw cloudtrail_name)

# Verify SSO Administrator access
terraform output sso_admin_role_arns
terraform output sso_admin_roles_found

# List SSO roles in Log Archive Account (from Management Account)
aws iam list-roles --query 'Roles[?contains(RoleName, `AWSReservedSSO_AWSAdministratorAccess`)].[RoleName,Arn]' --output table
```

## Cleanup

To remove all resources:

```bash
# Important: This will delete the S3 bucket and all CloudTrail logs!
terraform destroy
```

**Note**: If `force_destroy_s3_bucket = false` (default), you'll need to empty the S3 bucket manually before destroying.

## Support

For issues with this example:
1. Check the main module documentation
2. Verify your Control Tower setup
3. Ensure proper cross-account permissions
4. Review AWS CloudTrail documentation 