# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.14"
      version = ">= 4.65"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      #version = "~> 2.11"
      version = ">= 2.20"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-on-aws-eks"
    key    = "dev/eks-cloudwatch-agent/terraform.tfstate"
    region = "eu-west-3"

    # For State Locking
    dynamodb_table = "dev-eks-cloudwatch-agent"
  }
}

