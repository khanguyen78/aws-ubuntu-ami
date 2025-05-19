variable "create_instance_profile" {
  type    = bool
  default = true
}

variable "instance_profile_name" {
  type    = string
  default = ""
}


variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

