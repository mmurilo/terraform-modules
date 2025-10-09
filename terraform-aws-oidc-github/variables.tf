variable "tags" {
  description = "Tags to apply to created resources."
  type        = map(string)
  default     = null
}

variable "github_repositories" {
  description = "List of GitHub repositories allowed to assume the role. Format: 'owner/repo' or 'owner/repo:ref'."
  type        = list(string)
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider in this account. If false, an existing provider will be looked up by URL."
  type        = bool
  default     = true
}

variable "thumbprint" {
  description = "Thumbprint for the GitHub OIDC root certificate. Since July 2024, AWS uses trusted root CAs for GitHub's OIDC provider, making this optional. Only required for custom or self-signed certificates."
  type        = string
  default     = null
}

variable "github_actions_oidc_url" {
  description = "GitHub Actions OIDC issuer URL."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it."
  type        = bool
  default     = false
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) for the IAM role."
  type        = number
  default     = 5400
}

variable "iam_role_name" {
  description = "Name of the IAM role to create for GitHub OIDC."
  type        = string
  default     = "gh-oidc-role"
}

variable "iam_role_path" {
  description = "Path for the IAM role."
  type        = string
  default     = "/"
}

variable "iam_role_permissions_boundary" {
  description = "Permissions boundary ARN to attach to the IAM role (optional)."
  type        = string
  default     = null
}

variable "iam_role_inline_policies" {
  description = "Inline policy documents (JSON) to attach to the IAM role, keyed by policy name."
  type        = map(string)
  default     = {}
}

variable "iam_role_policy_arns" {
  description = "Set of managed policy ARNs to attach to the IAM role."
  type        = set(string)
  default     = []
}

variable "attach_read_only_policy" {
  description = "Attach AWS managed ReadOnlyAccess policy to the IAM role."
  type        = bool
  default     = true
}

variable "attach_admin_policy" {
  description = "Attach AWS managed AdministratorAccess policy to the IAM role."
  type        = bool
  default     = false
}

variable "attach_terraform_policy" {
  description = "Create and attach a Terraform automation policy (for remote state, KMS, and cross-account AssumeRole)."
  type        = bool
  default     = true
}

variable "tf_crossaccount_role" {
  description = "Default cross-account role name to assume across organization accounts (e.g., OrganizationAccountAccessRole)."
  type        = string
  default     = "AWSControlTowerExecution"
}

variable "tf_extra_roles" {
  description = "Additional role names to allow assuming across organization accounts."
  type        = list(string)
  default     = []
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state (required if attach_terraform_policy = true)."
  type        = string
  default     = null
}
