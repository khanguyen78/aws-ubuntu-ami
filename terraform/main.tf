provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "packer_user" {
  name = var.iam_user_name
}

resource "aws_iam_user_policy" "packer_policy" {
  name = "packer-ami-builder-policy"
  user = aws_iam_user.packer_user.name

  policy = data.aws_iam_policy_document.packer_permissions.json
}

data "aws_iam_policy_document" "packer_permissions" {
  statement {
    sid = "EC2Permissions"
    actions = [
      "ec2:Describe*",
      "ec2:CreateImage",
      "ec2:RegisterImage",
      "ec2:DeregisterImage",
      "ec2:CreateTags",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:CreateVolume",
      "ec2:AttachVolume",
      "ec2:DeleteVolume",
      "ec2:StopInstances",
      "ec2:StartInstances",
      "ec2:CreateKeyPair",
      "ec2:CreateSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:ModifyImageAttribute",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:DeleteLaunchTemplate"
    ]
    resources = ["*"]
  }
  statement {
    sid = "EC2DeleteSG"
    actions = [
      "ec2:DeleteSecurityGroup"
    ]
    #    condition = [
    #      stringequals = [
    #          "ec2:Name": "*packer*"
    #      ]
    #    ]
    resources = ["*"]
  }

  statement {
    sid = "EC2DeleteKeyPair"
    actions = [
      "ec2:DeleteKeypair"
    ]
    resources = ["*"]
  }

  statement {
    sid = "IAMPermissions"
    actions = [
      "iam:GetInstanceProfile",
      "iam:ListInstanceProfiles",
      "iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    sid = "SSMPermissions"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath"
    ]
    resources = ["*"]
  }


  statement {
    sid = "KMSPermissions"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_access_key" "packer_user_key" {
  user = aws_iam_user.packer_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.packer_user_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.packer_user_key.secret
  sensitive = true
}

