terraform {
  backend "s3" {
    bucket       = ""
    key          = "terraform/management/us-east-1/security-hardening/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
