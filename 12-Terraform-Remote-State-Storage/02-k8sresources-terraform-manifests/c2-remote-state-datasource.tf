# Terraform Remote State Datasource
/*
data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../../08-AWS-EKS-Cluster-Basics/01-ekscluster-terraform-manifests/terraform.tfstate"
   }
}
*/

# Terraform Remote State Datasource - Remote Backend AWS S3
# Bloc "data" pour récupérer l'état distant de Terraform
# Ce bloc permet d'accéder à l'état Terraform stocké dans un backend distant (ici, un bucket S3).
# L'état distant est souvent utilisé pour récupérer les outputs ou des informations provenant d'un autre module Terraform.
data "terraform_remote_state" "eks" {

  # Backend configuré pour utiliser S3
  backend = "s3"  # Indique que l'état distant est stocké dans un bucket S3

  # Configuration pour accéder au backend S3
  config = {
    bucket = "ingcloud-terraform-state"  # Le nom du bucket S3 où l'état Terraform est stocké
    key    = "dev/eks-cluster/terraform.tfstate"  # Le chemin vers le fichier d'état Terraform dans le bucket
    region = "eu-west-3"  # La région AWS où se trouve le bucket S3
  }
}
