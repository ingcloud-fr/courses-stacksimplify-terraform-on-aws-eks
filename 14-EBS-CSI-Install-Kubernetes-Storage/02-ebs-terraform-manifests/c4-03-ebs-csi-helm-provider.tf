# Datasource: EKS Cluster Authentication
# Ce bloc utilise le fournisseur de données "aws_eks_cluster_auth" pour récupérer un jeton d'authentification pour le cluster EKS spécifié.
# Ce jeton est nécessaire pour se connecter au cluster et exécuter des commandes via l'API Kubernetes.

data "aws_eks_cluster_auth" "cluster" {
  # Le nom du cluster EKS est récupéré depuis l'état distant de Terraform (Terraform Remote State).
  # L'état distant stocke les informations sur les ressources précédemment créées, telles que l'ID du cluster.
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

# Provider HELM
# Doc : https://registry.terraform.io/providers/hashicorp/helm/latest/docs 
# Ce bloc configure le fournisseur "helm" pour gérer les installations et mises à jour des charts Helm dans le cluster EKS.
# Helm est un outil de gestion de packages pour Kubernetes, permettant d'installer et de gérer des applications.
provider "helm" {
  kubernetes {
    # L'adresse de l'API du cluster Kubernetes (le point de terminaison du serveur API) est récupérée depuis l'état distant Terraform.
    host = data.terraform_remote_state.eks.outputs.cluster_endpoint

    # Le certificat d'autorité du cluster (CA) est également récupéré depuis l'état distant.
    # Il est ensuite décodé à partir de son format Base64 pour être utilisé par le fournisseur Helm.
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

    # Le jeton d'authentification pour se connecter au cluster EKS est obtenu à partir de la ressource "aws_eks_cluster_auth".
    # Ce jeton est utilisé pour s'authentifier auprès de l'API Kubernetes.
    token = data.aws_eks_cluster_auth.cluster.token
  }
}
