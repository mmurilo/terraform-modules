terraform {
  required_version = "> 0.14"

  required_providers {
    aws = {
      source  = "HASHICORP/AWS"
      version = "> 4.0"
    }
  }
}
