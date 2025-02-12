variable "namespace" {
  description = "which namespace the service account is in"
  type        = string
}

variable "service_account" {
  description = "the service account name in kubernetes"
  type        = string
}

variable "policy_statements" {
  description = "List of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement)"
  type        = any
}

variable "cluster_name" {
  description = "eks cluster name"
  type        = string
}

variable "create_sa" {
  description = "create the service account or not"
  type        = bool
  default     = false
}
