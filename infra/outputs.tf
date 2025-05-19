output "pipeline_arn" {
  value = aws_imagebuilder_image_pipeline.pipeline.arn
}

output "instance_profile_name" {
  value = var.create_instance_profile ? aws_iam_instance_profile.ec2_imagebuilder_profile[0].name : var.instance_profile_name
}

output "github_ci_access_key_id" {
  value       = aws_iam_access_key.github_ci_access_key.id
  sensitive   = false
}

output "github_ci_secret_access_key" {
  value       = aws_iam_access_key.github_ci_access_key.secret
  sensitive   = true
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "security_group_id" {
  value = aws_security_group.ci_sg.id
}

