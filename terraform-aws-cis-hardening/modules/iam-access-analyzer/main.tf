data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

################################################################################
# Random String for Analyzer Name
################################################################################

resource "random_string" "analyzer_suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  create_analyzer = var.create_analyzer

  # Determine analyzer type based on configuration
  analyzer_type = var.type == "ORGANIZATION" ? "ORGANIZATION" : (
    var.type == "ORGANIZATION_UNUSED_ACCESS" ? "ORGANIZATION_UNUSED_ACCESS" : "ACCOUNT"
  )

  # Set default analyzer name based on type if not provided
  default_analyzer_name = var.analyzer_name != null ? var.analyzer_name : (
    local.analyzer_type == "ORGANIZATION" ? "OrganizationExternalAccessAnalyzer-${random_string.analyzer_suffix.result}" : (
      local.analyzer_type == "ORGANIZATION_UNUSED_ACCESS" ? "OrganizationUnusedAccessAnalyzer-${random_string.analyzer_suffix.result}" : "AccountExternalAccessAnalyzer-${random_string.analyzer_suffix.result}"
    )
  )

  # Archive rules configuration
  archive_rules = var.archive_rules
}

################################################################################
# IAM Access Analyzer
################################################################################

resource "aws_accessanalyzer_analyzer" "this" {
  count = local.create_analyzer ? 1 : 0

  analyzer_name = local.default_analyzer_name
  type          = local.analyzer_type

  dynamic "configuration" {
    for_each = var.type == "ORGANIZATION_UNUSED_ACCESS" && var.unused_access_configuration != null ? [var.unused_access_configuration] : []
    content {
      unused_access {
        unused_access_age = configuration.value.unused_access_age
      }
    }
  }

  tags = var.tags
}

################################################################################
# Archive Rules
################################################################################

resource "aws_accessanalyzer_archive_rule" "this" {
  for_each = local.create_analyzer ? local.archive_rules : {}

  analyzer_name = aws_accessanalyzer_analyzer.this[0].analyzer_name
  rule_name     = each.key

  dynamic "filter" {
    for_each = each.value.filters
    content {
      criteria = filter.value.criteria
      contains = try(filter.value.contains, null)
      eq       = try(filter.value.eq, null)
      exists   = try(filter.value.exists, null)
      neq      = try(filter.value.neq, null)
    }
  }
}
