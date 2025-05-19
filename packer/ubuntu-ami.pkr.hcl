packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.0.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_users" {
  type    = list(string)
  default = ["123456789012"]  # Replace with actual AWS Account ID(s) to share with
}

source "amazon-ebs" "ubuntu" {
  region                  = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  ami_name                = "ubuntu-ami-with-ansible-{{timestamp}}"
  ami_description         = "Ubuntu 22.04 LTS hardened and provisioned via Ansible"
  instance_type           = "t3.micro"
  ssh_username            = "ubuntu"
  ami_users               = var.ami_users
  tags = {
    Name        = "Ubuntu-AMI-With-Ansible"
    Environment = "production"
    Owner       = "GitHubActions"
  }
}

build {
  name    = "ubuntu-ami-ansible"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "ansible" {
    playbook_file = "ansible/playbook.yml"
  }
}

