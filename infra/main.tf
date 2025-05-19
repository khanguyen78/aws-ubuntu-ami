provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_imagebuilder_component" "harden" {
  name        = "ubuntu-hardening-component"
  platform    = "Linux"
  version     = "1.0.0"
  data        = file("${path.module}/harden.yml")
  description = "Harden Ubuntu using shell script or Ansible"
}

resource "aws_imagebuilder_infrastructure_configuration" "infra" {
  name                          = "ubuntu-ami-infra"
  instance_types                = ["t3.micro"]
  terminate_instance_on_failure = true
  instance_profile_name         = var.instance_profile_name
  security_group_ids            = [var.security_group_id]
  subnet_id                     = var.subnet_id
  instance_profile_name = var.create_instance_profile ? aws_iam_instance_profile.ec2_imagebuilder_profile[0].name : var.instance_profile_name

}

resource "aws_imagebuilder_image_recipe" "recipe" {
  name         = "ubuntu-ami-recipe"
  version      = "1.0.0"
  parent_image = var.ami_id

  block_device_mapping {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 10
      volume_type = "gp2"
    }
  }

  component {
    component_arn = aws_imagebuilder_component.harden.arn
  }
}

resource "aws_imagebuilder_image_pipeline" "pipeline" {
  name                             = "ubuntu-ami-pipeline"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.infra.arn
  schedule {
    schedule_expression = "rate(7 days)"  # Can be cron or on-demand
  }
  status = "ENABLED"
}

