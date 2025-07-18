variable "create_analyzer" {
  description = "Controls if IAM Access Analyzer should be created"
  type        = bool
  default     = true
}

variable "analyzer_name" {
  description = "Name of the analyzer. If not provided, a default name will be used based on analyzer type"
  type        = string
  default     = null
}

variable "type" {
  description = "Type of analyzer. Valid values are ACCOUNT, ORGANIZATION, ORGANIZATION_UNUSED_ACCESS"
  type        = string
  default     = "ACCOUNT"

  validation {
    condition = contains([
      "ACCOUNT",
      "ORGANIZATION",
      "ORGANIZATION_UNUSED_ACCESS"
    ], var.type)
    error_message = "Analyzer type must be one of: ACCOUNT, ORGANIZATION, ORGANIZATION_UNUSED_ACCESS."
  }
}

variable "unused_access_configuration" {
  description = "Configuration for unused access analyzer. Only applicable when type is ORGANIZATION_UNUSED_ACCESS"
  type = object({
    unused_access_age = number
  })
  default = null
}

variable "archive_rules" {
  description = "Map of archive rules to create for the analyzer"
  type = map(object({
    filters = list(object({
      criteria = string
      contains = optional(list(string))
      eq       = optional(list(string))
      exists   = optional(string)
      neq      = optional(list(string))
    }))
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to the analyzer"
  type        = map(string)
  default     = {}
}
