terraform {
  required_version = ">= 1.6.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.21.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.0"
    }
  }
}