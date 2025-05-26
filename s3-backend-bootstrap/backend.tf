terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "HASHICORP/AWS"
      version = "> 5.0"
    }
  }
}
