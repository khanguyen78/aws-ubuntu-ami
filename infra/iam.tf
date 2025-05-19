resource "aws_iam_role" "ec2_imagebuilder_role" {
  count = var.create_instance_profile ? 1 : 0

  name = "EC2ImageBuilderInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ec2_imagebuilder_policy" {
  count = var.create_instance_profile ? 1 : 0

  name        = "EC2ImageBuilderPolicy"
  description = "Permissions for EC2 Image Builder instances"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:GetParameters",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations",
        "ssm:PutInventory",
        "ssm:PutComplianceItems",
        "ssm:PutConfigurePackageResult",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:UpdateInstanceInformation",
        "ssmmessages:*",
        "ec2messages:*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "cloudwatch:PutMetricData",
        "ec2:Describe*",
        "ec2:AttachVolume",
        "ec2:DetachVolume"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_imagebuilder_attach" {
  count      = var.create_instance_profile ? 1 : 0
  role       = aws_iam_role.ec2_imagebuilder_role[0].name
  policy_arn = aws_iam_policy.ec2_imagebuilder_policy[0].arn
}

resource "aws_iam_instance_profile" "ec2_imagebuilder_profile" {
  count = var.create_instance_profile ? 1 : 0
  name  = "EC2ImageBuilderInstanceProfile"
  role  = aws_iam_role.ec2_imagebuilder_role[0].name
}

