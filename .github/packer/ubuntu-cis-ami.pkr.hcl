variable "region" {
  default = "us-east-1"
}

variable "PACKER_DESTINATION_PATH" {
  type    = string
  default = "/home/ubuntu"
}

##################################################################################

source "amazon-ebs" "ubuntu" {
  region = var.region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  instance_type   = "t3.large"
  ssh_username    = "ubuntu"
  ami_name        = "ctac-noc-ubuntu-22.04-BASE-{{timestamp}}"
  ami_description = "Ubuntu 22.04 AMI hardened with CIS Level 1"

  # Spot Instance Configuration
  spot_price = "auto"

  # Root volume mapping (optional override)
  # root
  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 5
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # ➕ Additional EBS volume
  # /home
  launch_block_device_mappings {
    device_name           = "/dev/sdb"
    volume_size           = 5
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # ➕  Additional EBS volume
  # /var
  launch_block_device_mappings {
    device_name           = "/dev/sdc"
    volume_size           = 5
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

  }

  # ➕   Additional EBS volume
  # /var/log
  launch_block_device_mappings {
    device_name           = "/dev/sdd"
    volume_size           = 5
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # ➕   Additional EBS volume
  # /var/log/audit
  launch_block_device_mappings {
    device_name           = "/dev/sde"
    volume_size           = 5
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # ➕   Additional EBS volume
  # /var/tmp
  launch_block_device_mappings {
    device_name           = "/dev/sdf"
    volume_size           = 5
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # ➕   Additional EBS volume
  # /tmp
  launch_block_device_mappings {
    device_name           = "/dev/sdg"
    volume_size           = 5
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # ➕   Additional EBS volume
  # /appdata
  launch_block_device_mappings {
    device_name           = "/dev/sdh"
    volume_size           = 5
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  run_tags = {
    Compliance       = "cis-benchmark"
    CostCenter       = "SharedServices"
    Customer         = "noc"
    Name             = "ctac-noc-ubuntu-22.04-BASE"
    Owner            = "noc"
    Project_baseline = "true"
    Role             = "base-ami"
    Security         = "moderate"
  }
  run_volume_tags = {
    Name                  = "ctac-noc-ubuntu-22.04-BASE"
    MakeSnapshot          = "false"
    delete_on_termination = true
    encrypted             = true
  }
  tags = {
    Compliance       = "cis-benchmark"
    CostCenter       = "SharedServices"
    Customer         = "noc"
    Name             = "ctac-noc-ubuntu-22.04-BASE"
    Owner            = "noc"
    Project_baseline = "true"
    Role             = "base-ami"
    Security         = "moderate"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "../../scripts/install_awscli.sh"
  }

  provisioner "shell" {
    script = "../../scripts/install_ssm_agent.sh"
  }

  provisioner "shell" {
    script = "../../scripts/install_session_manager.sh"
  }

  provisioner "shell" {
    script = "../../scripts/init.sh"
  }

  provisioner "shell" {
    script = "../../scripts/harden.sh"
  }

  provisioner "file" {
    source      = "../../scripts/paramstore/init-ssm-paramstore.sh"
    destination = "/tmp/init-ssm-paramstore.sh"
  }

  provisioner "file" {
    source      = "../../scripts/paramstore/templates"
    destination = "/tmp/templates"
  }

  provisioner "file" {
    source = "../../scripts/paramstore/ssm-paramstore.service"
    destination = "/tmp/ssm-paramstore.service"
  }

  provisioner "file" {
    source      = "../../scripts/paramstore/ssm_paramstore.py"
    destination = "/tmp/ssm_paramstore.py"
  }

  provisioner "file" {
    source      = "../../scripts/paramstore/config.py"
    destination = "/tmp/config.py"
  }

  provisioner "shell" {
    script = "../../scripts/install_ssm_paramstore.sh"
  }
  
  provisioner "ansible" {
    playbook_file = "../ansible/playbok.yml"
  }

  provisioner "shell" {
    script = "../../scripts/partitioning.sh"
  }

}
