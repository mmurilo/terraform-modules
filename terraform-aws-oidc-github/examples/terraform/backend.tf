terraform {
  backend "s3" {
    bucket       = ""
    key          = "terraform/management/us-east-1/oidc-github/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
