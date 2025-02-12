variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Akuity
################################################################################
variable "create" {
  description = "Whether the Akuity addon is enabled"
  type        = bool
  default     = false
}

variable "akuity_name" {
  description = "Name of the Akuity installation"
  type        = string
}

variable "akuity_instance_id" {
  description = "Akuity instance ID"
  type        = string
}

variable "akuity_namespace" {
  description = "Akuity addon installation namespace"
  type        = string
}

variable "akuity_agent_size" {
  description = "Akuity agent installation size"
  type        = string

  validation {
    condition     = contains(["small", "medium", "large"], var.akuity_agent_size)
    error_message = "Allowed values for input_parameter are \"small\", \"medium\", or \"large\"."
  }
}


################################################################################
# Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}