provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "github_ci" {
  name = "github-ci-packer-user"
  tags = {
    ManagedBy = "Terraform"
    Purpose   = "GitHubActions-CIS-AMI-Build"
  }
}

resource "aws_iam_access_key" "github_ci_key" {
  user = aws_iam_user.github_ci.name
}

resource "aws_iam_policy" "github_ci_policy" {
  name        = "GitHubCISPackerPolicy"
  description = "Minimal permissions for GitHub Actions to build CIS AMIs and upload reports"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "ssm:*",
          "ssmmessages:*",
          "ec2messages:*",
          "imagebuilder:*",
          "iam:PassRole",
          "logs:*",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_ci_attach" {
  user       = aws_iam_user.github_ci.name
  policy_arn = aws_iam_policy.github_ci_policy.arn
}

