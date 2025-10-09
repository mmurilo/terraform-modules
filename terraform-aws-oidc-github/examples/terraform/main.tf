provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "prod"
    }
  }
}

module "oidc-github" {
  source = "../../"

  state_bucket_name = ""
  github_repositories = [
    "some-org/some-repo",
  ]
}
