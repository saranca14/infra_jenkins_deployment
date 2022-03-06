terraform {
  backend "s3" {
    bucket     = "ca14-infra-jenkins-deployment"
    key        = "remote_tfstate.tf"
    region     = "ap-south-1"
    access_key = "AKIAZ3NZJHNTRTHVUFUG"
    secret_key = "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"
  }
}
