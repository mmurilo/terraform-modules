################################################################################
# IAM Access Analyzer
################################################################################

output "analyzer_arn" {
  description = "ARN of the IAM Access Analyzer"
  value       = try(aws_accessanalyzer_analyzer.this[0].arn, null)
}

output "analyzer_id" {
  description = "ID of the IAM Access Analyzer"
  value       = try(aws_accessanalyzer_analyzer.this[0].id, null)
}

output "analyzer_name" {
  description = "Name of the IAM Access Analyzer"
  value       = try(aws_accessanalyzer_analyzer.this[0].analyzer_name, null)
}

output "analyzer_type" {
  description = "Type of the IAM Access Analyzer"
  value       = try(aws_accessanalyzer_analyzer.this[0].type, null)
}

################################################################################
# Archive Rules
################################################################################

output "archive_rules" {
  description = "Map of archive rules created"
  value       = aws_accessanalyzer_archive_rule.this
}
