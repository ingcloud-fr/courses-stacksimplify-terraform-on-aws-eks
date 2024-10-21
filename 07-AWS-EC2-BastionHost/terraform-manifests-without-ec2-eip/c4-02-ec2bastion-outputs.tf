# AWS EC2 Instance Terraform Outputs
# Public EC2 Instances - Bastion Host

output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = module.ec2_public.public_ip
}