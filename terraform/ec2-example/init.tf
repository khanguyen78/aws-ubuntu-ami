terraform {
  backend "s3" {
    bucket  = "ctac-sysadmin-state"
    key     = "terraform/test-ubuntu22"
    encrypt = "true"
    region  = "us-east-1"
  }
}