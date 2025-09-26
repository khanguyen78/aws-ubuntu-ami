terraform {
  backend "s3" {
    bucket         = "ctac-sysadmin-state"            # Replace with your bucket
    key            = "iam/packer-user-cis-ubuntu-ami/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    #dynamodb_table = "terraform-locks"               # Optional, for state locking
  }
}

