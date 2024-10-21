# AWS EC2 Security Group Terraform Module
# Doc : https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest 
# Security Group for Public Bastion Host
module "public_bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "4.5.0"  
  #version = "4.17.2"
  version = "~> 5.0"

  name        = "${local.name}-public-bastion-sg"
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id      = module.vpc.vpc_id
  # Ingress Rules & CIDR Blocks
  # Accès SSH depuis n'importe où
  # ingress_rules       = ["ssh-tcp"]
  # ingress_cidr_blocks = ["0.0.0.0/0"]

  # Limiter l'accès à une IP uniquement pour SSH, HTTP et HTTPS
  # Ingress Rules with CIDR Blocks
  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.my_ip
    },
    {
      rule        = "http-80-tcp"
      cidr_blocks = var.my_ip
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = var.my_ip
    }
  ]
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags         = local.common_tags
}