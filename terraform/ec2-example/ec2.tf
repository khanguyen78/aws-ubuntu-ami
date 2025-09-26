data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ctac-noc-ubuntu-22.04-BASE*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["623597234510"] # Canonical
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  iam_instance_profile        = "AmazonSSMRoleForInstancesQuickSetup"
  key_name                    = "noc-app-stg-v1"
  vpc_security_group_ids      = ["sg-bf4625d9"]
  subnet_id = "subnet-f16067da"
  user_data_replace_on_change = false


  tags = {
    Name = "test-ubuntu22"
  }
}