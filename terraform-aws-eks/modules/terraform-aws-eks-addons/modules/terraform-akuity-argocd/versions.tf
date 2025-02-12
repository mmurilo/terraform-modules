terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
    akp = {
      source  = "akuity/akp"
      version = ">= 0.7.1"
    }
  }
}
