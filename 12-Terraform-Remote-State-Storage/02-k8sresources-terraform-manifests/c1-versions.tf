# Terraform Settings Block
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = ">= 4.65"
      version = ">= 5.31"
      
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      #version = "~> 2.7"
      version = ">= 2.30"
    }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "ingcloud-terraform-state"
    key    = "dev/app1k8s/terraform.tfstate"
    region = "eu-west-3"

    # For State Locking
    dynamodb_table = "tf-dev-app1k8s"
  }
}
