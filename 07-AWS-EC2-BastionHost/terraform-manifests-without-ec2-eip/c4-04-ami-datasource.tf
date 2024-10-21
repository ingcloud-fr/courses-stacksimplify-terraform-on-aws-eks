# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  ## Pour Amazon Linux
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  # Type de périphérique racine : EBS
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  # Type de virtualisation : hvm
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "ubuntu2204" {
  most_recent = true

  owners = ["099720109477"] # Owner Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  # Type de périphérique racine : EBS
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  # Type de virtualisation : hvm
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}