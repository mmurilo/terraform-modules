variable "product_name" {
  description = "The name of the AWS Service Catalog product."
  type        = string
  default     = "AWS Control Tower Account Factory"
}

variable "provisioning_artifact_name" {
  description = "The name of the provisioning artifact (e.g., product version) for the Account Factory. Example: \"v1.2.3\"."
  type        = string
  default     = "AWS Control Tower Account Factory"
}

variable "product_id" {
  description = "The ID of the AWS Service Catalog product."
  type        = string
  default     = null
}

variable "provisioning_artifact_id" {
  description = "The ID of the AWS Service Catalog provisioning artifact."
  type        = string
  default     = null
}


variable "accounts" {
  description = "A map of accounts to be provisioned. Each account requires parameters matching those expected by the Account Factory product."
  type = map(object({
    # Required Account Factory parameters
    AccountName               = string
    AccountEmail              = string
    ManagedOrganizationalUnit = string
    SSOUserEmail              = optional(string)
    SSOUserFirstName          = optional(string)
    SSOUserLastName           = optional(string)
    AccountId                 = optional(string)

    # Optional IAM Identity Center group assignments
    sso_group_assignments = optional(map(list(string)), {})

    # Additional optional Account Factory parameters
    # These will be passed through to the provisioning product
  }))

  validation {
    condition     = length(var.accounts) > 0
    error_message = "At least one account must be specified."
  }
}

variable "tags" {
  description = "A map of additional tags to apply to the provisioned products."
  type        = map(string)
  default     = {}
}

variable "default_SSOUserEmail" {
  description = "Default SSO user email to use when an account doesn't specify one"
  type        = string
  default     = null
}

variable "default_SSOUserFirstName" {
  description = "Default SSO user first name to use when an account doesn't specify one"
  type        = string
  default     = null
}

variable "default_SSOUserLastName" {
  description = "Default SSO user last name to use when an account doesn't specify one"
  type        = string
  default     = null
}
