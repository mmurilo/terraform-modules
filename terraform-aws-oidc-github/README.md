# AWS GitHub OIDC Terraform Module

This Terraform module creates an AWS IAM OpenID Connect (OIDC) identity provider and IAM role for GitHub Actions workflows to authenticate with AWS services without storing long-lived credentials.

## Recent Updates

### October 2024 - Fixed OIDC Client ID Configuration
- **CRITICAL FIX**: Corrected `client_id_list` to only include `sts.amazonaws.com` (as per GitHub/AWS OIDC specification)
- **Previous Issue**: Module was incorrectly including GitHub organization URLs in the client ID list, causing authentication failures
- **Impact**: This fix resolves "Not authorized to perform sts:AssumeRoleWithWebIdentity" errors
- **Action Required**: If you deployed the module before this fix, you need to run `terraform apply` to update the OIDC provider

### July 2024 - Enhanced Certificate Validation
- **New Security Model**: AWS now secures communication with OIDC identity providers by trusting root certificate authorities (CAs) that anchor the IdP's SSL/TLS server certificate
- **Automatic Certificate Management**: AWS automatically retrieves and validates certificates for OIDC providers using trusted root CAs (like GitHub)
- **Reduced Maintenance**: No more manual thumbprint updates when SSL/TLS certificates rotate
- **Trusted Root CA**: GitHub's OIDC provider uses trusted root certificate authorities
- **No Thumbprint Required**: Certificate thumbprints are no longer needed for security validation
- **Automatic Setup**: AWS handles certificate verification automatically

### Backward Compatibility
- **Custom CAs**: Thumbprints are still required for less common root CAs or self-signed certificates
- **Fallback Mechanism**: AWS falls back to thumbprint verification when unable to retrieve TLS certificates or when TLS v1.3 is required

## Security Best Practices

This module implements the following security measures:

1. **Repository Restriction**: Access is limited to specified GitHub repositories using the `sub` claim
2. **Audience Validation**: Tokens must be intended for AWS STS (`sts.amazonaws.com`)
3. **Issuer Validation**: Tokens must originate from GitHub's OIDC provider
4. **Principle of Least Privilege**: IAM roles can be configured with minimal required permissions
5. **Session Policies**: Support for inline and managed session policies to further restrict permissions

## Usage Examples

### Basic Setup (Recommended)
```hcl
module "github_oidc" {
  source = "./aws-modules/terraform-aws-oidc-github"

  github_repositories = [
    "my-org/my-repo",
    "my-org/another-repo:ref:refs/heads/main"
  ]
   
  # Optional: Attach specific policies
  iam_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}
```

## GitHub Actions Workflow

Once the module is deployed, use the role in your GitHub Actions workflow:

```yaml
name: Deploy to AWS
on:
  push:
    branches: [main]

permissions:
  id-token: write   # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v5.0.0
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
          role-session-name: GitHubActions
          aws-region: us-east-1
      
      - name: Deploy application
        run: |
          aws sts get-caller-identity
          # Your deployment commands here
```

## Migration from Legacy Setups

If you're migrating from a setup using hardcoded thumbprints:

1. **Remove thumbprint variable**: The `thumbprint` variable can be removed from your configuration
2. **Update existing providers**: Existing OIDC providers will automatically use the new security model
3. **No downtime**: Changes are backward compatible and applied automatically

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_admin_policy"></a> [attach\_admin\_policy](#input\_attach\_admin\_policy) | Attach AWS managed AdministratorAccess policy to the IAM role. | `bool` | `false` | no |
| <a name="input_attach_read_only_policy"></a> [attach\_read\_only\_policy](#input\_attach\_read\_only\_policy) | Attach AWS managed ReadOnlyAccess policy to the IAM role. | `bool` | `true` | no |
| <a name="input_attach_terraform_policy"></a> [attach\_terraform\_policy](#input\_attach\_terraform\_policy) | Create and attach a Terraform automation policy (for remote state, KMS, and cross-account AssumeRole). | `bool` | `true` | no |
| <a name="input_create_oidc_provider"></a> [create\_oidc\_provider](#input\_create\_oidc\_provider) | Whether to create the GitHub OIDC provider in this account. If false, an existing provider will be looked up by URL. | `bool` | `true` | no |
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Whether to force detaching any policies the role has before destroying it. | `bool` | `false` | no |
| <a name="input_github_actions_oidc_url"></a> [github\_actions\_oidc\_url](#input\_github\_actions\_oidc\_url) | GitHub Actions OIDC issuer URL. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_github_repositories"></a> [github\_repositories](#input\_github\_repositories) | List of GitHub repositories allowed to assume the role. Format: 'owner/repo' or 'owner/repo:ref'. | `list(string)` | n/a | yes |
| <a name="input_iam_role_inline_policies"></a> [iam\_role\_inline\_policies](#input\_iam\_role\_inline\_policies) | Inline policy documents (JSON) to attach to the IAM role, keyed by policy name. | `map(string)` | `{}` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role to create for GitHub OIDC. | `string` | `"gh-oidc-role"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Path for the IAM role. | `string` | `"/"` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | Permissions boundary ARN to attach to the IAM role (optional). | `string` | `null` | no |
| <a name="input_iam_role_policy_arns"></a> [iam\_role\_policy\_arns](#input\_iam\_role\_policy\_arns) | Set of managed policy ARNs to attach to the IAM role. | `set(string)` | `[]` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration (in seconds) for the IAM role. | `number` | `5400` | no |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | S3 bucket name for Terraform remote state (required if attach\_terraform\_policy = true). | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to created resources. | `map(string)` | `null` | no |
| <a name="input_tf_crossaccount_role"></a> [tf\_crossaccount\_role](#input\_tf\_crossaccount\_role) | Default cross-account role name to assume across organization accounts (e.g., OrganizationAccountAccessRole). | `string` | `"AWSControlTowerExecution"` | no |
| <a name="input_tf_extra_roles"></a> [tf\_extra\_roles](#input\_tf\_extra\_roles) | Additional role names to allow assuming across organization accounts. | `list(string)` | `[]` | no |
| <a name="input_thumbprint"></a> [thumbprint](#input\_thumbprint) | Thumbprint for the GitHub OIDC root certificate. Since July 2024, AWS uses trusted root CAs for GitHub's OIDC provider, making this optional. Only required for custom or self-signed certificates. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role. |
<!-- END_TF_DOCS -->