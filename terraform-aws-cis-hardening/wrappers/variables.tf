variable "defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}

variable "items" {
  description = "Map of items to create a wrapper over. Values are passed through to the module."
  type        = any
  default     = {}
}
