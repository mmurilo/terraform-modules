variable "region" {
  type        = string
  description = "AWS region to cretate resources"
  default     = null
}
variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
  default     = null
}
variable "lifecycle_delete" {
  type        = number
  description = "After how many days delete versioned objects"
  default     = 90
}
variable "creator" {
  type    = string
  default = "terraform"
}
