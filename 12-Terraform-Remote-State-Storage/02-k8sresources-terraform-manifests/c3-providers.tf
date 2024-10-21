# Fournisseur AWS (AWS Provider Block)
# Ce bloc spécifie la région AWS dans laquelle les ressources vont être créées ou gérées.
provider "aws" {
  region = "eu-west-3"  # Région AWS (Paris) dans laquelle Terraform va interagir avec les ressources AWS.
}

# Données pour récupérer les informations du cluster EKS
# Ce bloc de données extrait les informations du cluster EKS, comme l'ID du cluster.
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id  # Nom du cluster EKS récupéré depuis l'état distant (remote state) de Terraform.
}

# Données pour l'authentification auprès du cluster EKS
# Ce bloc récupère les informations nécessaires à l'authentification auprès du cluster EKS.
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id  # Utilise l'ID du cluster EKS pour récupérer les informations d'authentification.
}

# Fournisseur Kubernetes (Kubernetes Provider Block)
# Ce bloc permet à Terraform de se connecter au cluster Kubernetes via les informations fournies par AWS EKS.
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint  # Utilise l'endpoint du cluster EKS pour se connecter.
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)  # Décode et utilise le certificat d'autorité du cluster.
  token                  = data.aws_eks_cluster_auth.cluster.token  # Utilise le jeton d'authentification généré pour accéder au cluster.
}
