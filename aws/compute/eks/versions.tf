terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.50.0, < 7.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
