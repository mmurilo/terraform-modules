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
variable "dynamodb_table_name" {
  type    = string
  default = "tf-state-lock"
}
variable "billing_mode" {
  type        = string
  description = "DynamoDB billing mode"
  default     = "PAY_PER_REQUEST"
}
variable "read_capacity" {
  type        = number
  description = "DynamoDB read capacity units when using provisioned mode"
  default     = 5
}
variable "write_capacity" {
  type        = number
  description = "DynamoDB write capacity units when using provisioned mode"
  default     = 5
}
variable "enable_point_in_time_recovery" {
  type        = bool
  description = "Enable DynamoDB point-in-time recovery"
  default     = true
}
variable "creator" {
  type    = string
  default = "terraform"
}
