output "tfstate_bucket_name" {
  description = "The TFState bucket name."
  value       = module.tf_state.s3_bucket_id
}

output "tfstate_bucket_arn" {
  description = "The TFState bucket ARN."
  value       = module.tf_state.s3_bucket_arn
}

output "tfstate_bucket_region" {
  description = "The AWS region TFState bucket resides in."
  value       = module.tf_state.s3_bucket_region
}
