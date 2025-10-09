locals {
  region = "us-east-1"
  accounts_name_id = {
    for account in data.aws_organizations_organization.this.non_master_accounts :
    account.name => account.id if account.status == "ACTIVE"
  }
}
data "aws_organizations_organization" "this" {}

module "stacksets" {
  source = "../../"
  providers = {
    aws.log_archive = aws.LogArchive
  }

  log_archive_account_id = local.accounts_name_id["LogArchive"]
  stacksets_organizational_unit_ids = [
    "ou-abcd-12345678", # Security
    "ou-efgh-67890123", # Workloads
  ]

}

module "management" {
  source = "../../modules/security-baseline"

}
