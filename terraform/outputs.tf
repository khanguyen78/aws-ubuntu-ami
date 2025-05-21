output "github_ci_access_key_id" {
  value       = aws_iam_access_key.github_ci_key.id
  description = "Access Key ID for GitHub Actions"
  sensitive   = true
}

output "github_ci_secret_access_key" {
  value       = aws_iam_access_key.github_ci_key.secret
  description = "Secret Access Key for GitHub Actions"
  sensitive   = true
}

