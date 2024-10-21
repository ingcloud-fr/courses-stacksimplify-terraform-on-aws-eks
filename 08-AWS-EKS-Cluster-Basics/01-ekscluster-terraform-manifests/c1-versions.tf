# Bloc de configuration de Terraform
terraform {
  required_version = ">= 1.8.0" # Spécifie la version minimale de Terraform requise
  required_providers {
    aws = {
      source = "hashicorp/aws" # Fournisseur AWS
      #version = ">= 5.72"       # Version minimale requise du fournisseur AWS (même majeure)
      version = "~> 5.72" # Contrainte de compatibilité mineure
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

# Bloc fournisseur Terraform pour AWS
provider "aws" {
  region = var.aws_region # Récupère la région AWS depuis les variables
  default_tags {
    tags = {
      Managed = "ByTerraform"
    }
  }
}

