output "pipeline_arn" {
  value = aws_imagebuilder_image_pipeline.pipeline.arn
}

output "instance_profile_name" {
  value = var.create_instance_profile ? aws_iam_instance_profile.ec2_imagebuilder_profile[0].name : var.instance_profile_name
}

