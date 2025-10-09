provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Terraform = "true"
      Module    = "security-hardening"

    }
  }
}

provider "aws" {
  region = local.region
  alias  = "LogArchive"
  assume_role {
    role_arn = "arn:aws:iam::${local.accounts_name_id["LogArchive"]}:role/AWSControlTowerExecution"
  }
  default_tags {
    tags = {
      Terraform = "true"
      Module    = "security-hardening"
    }
  }
}
