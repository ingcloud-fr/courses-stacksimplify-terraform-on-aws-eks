# AWS EC2 Instance Terraform Module
# Bastion Host - EC2 Instance that will be created in VPC Public Subnet
# Doc : https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
module "ec2_public" {
  source = "terraform-aws-modules/ec2-instance/aws"
  #version = "~> 3.0"
  #version = "3.3.0"
  version = "5.0.0"

  name          = "${local.name}-BastionHost"
  ami           = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  key_name      = var.instance_keypair
  #monitoring             = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.public_bastion_sg.security_group_id]
  associate_public_ip_address = true

  tags = local.common_tags
}