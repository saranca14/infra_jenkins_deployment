terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "4.19.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAZ3NZJHNTRTHVUFUG"
  secret_key = "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"
}