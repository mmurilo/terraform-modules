terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    akp = {
      source  = "akuity/akp"
      version = ">= 0.7.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}
