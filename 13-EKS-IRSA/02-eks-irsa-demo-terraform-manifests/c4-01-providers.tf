# Terraform AWS Provider Block
# Ce bloc définit le fournisseur AWS pour Terraform. Il configure Terraform pour interagir avec les services AWS.
# La région spécifiée ici est "eu-west-3" (Paris).
provider "aws" {
  region = "eu-west-3"
}

# Datasource: Récupérer les informations du cluster EKS
# Ce bloc utilise le fournisseur de données "aws_eks_cluster" pour obtenir des détails sur un cluster EKS spécifique.
# Le nom du cluster est récupéré depuis l'état distant Terraform, ce qui permet d'utiliser les informations du cluster existant.
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id  # Récupère l'ID du cluster EKS depuis l'état distant.
}

# Datasource: Récupérer les informations d'authentification du cluster EKS
# Ce bloc utilise le fournisseur de données "aws_eks_cluster_auth" pour obtenir un jeton d'authentification pour le cluster EKS.
# Ce jeton est nécessaire pour se connecter au cluster et exécuter des commandes via l'API Kubernetes.
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id  # Récupère l'ID du cluster EKS depuis l'état distant.
}

# Terraform Kubernetes Provider Block
# Ce bloc définit le fournisseur Kubernetes pour Terraform, en utilisant les informations récupérées depuis les ressources AWS.
# Il configure Terraform pour interagir avec l'API Kubernetes et gérer les ressources du cluster.
provider "kubernetes" {
  # URL de l'API du cluster Kubernetes (point de terminaison du serveur API).
  # Cette URL est récupérée depuis l'état distant Terraform.
  host = data.terraform_remote_state.eks.outputs.cluster_endpoint

  # Certificat de l'autorité de certification du cluster, utilisé pour sécuriser les communications avec l'API Kubernetes.
  # Le certificat est récupéré en Base64 et décodé pour être utilisé.
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

  # Jeton d'authentification pour se connecter au cluster EKS.
  # Ce jeton est obtenu à partir de la ressource de données "aws_eks_cluster_auth".
  token = data.aws_eks_cluster_auth.cluster.token
}
