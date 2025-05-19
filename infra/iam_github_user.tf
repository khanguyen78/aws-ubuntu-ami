resource "aws_iam_user" "github_ci_user" {
  name = "github-ci-user"
}

resource "aws_iam_access_key" "github_ci_access_key" {
  user = aws_iam_user.github_ci_user.name
}

resource "aws_iam_policy" "github_ci_policy" {
  name = "GitHubCICDPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # EC2 AMI & instance actions for Packer
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateImage",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:ModifyImageAttribute",
          "ec2:CopyImage",
          "ec2:RegisterImage"
        ],
        Resource = "*"
      },

      # SSM for provisioning (Ansible, etc.)
      {
        Effect = "Allow",
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommands",
          "ssm:DescribeInstanceInformation",
          "ssmmessages:*",
          "ec2messages:*"
        ],
        Resource = "*"
      },

      # Image Builder
      {
        Effect = "Allow",
        Action = [
          "imagebuilder:StartImagePipelineExecution",
          "imagebuilder:GetImagePipeline",
          "imagebuilder:GetImage",
          "imagebuilder:ListImagePipelines",
          "imagebuilder:ListImages",
          "imagebuilder:CreateImagePipeline",
          "imagebuilder:CreateInfrastructureConfiguration",
          "imagebuilder:CreateImageRecipe"
        ],
        Resource = "*"
      },

      # Logging
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },

      # IAM PassRole (used when launching EC2 with instance profiles)
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = "*",
        Condition = {
          StringLike = {
            "iam:PassedToService" : "ec2.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_github_ci_policy" {
  user       = aws_iam_user.github_ci_user.name
  policy_arn = aws_iam_policy.github_ci_policy.arn
}

