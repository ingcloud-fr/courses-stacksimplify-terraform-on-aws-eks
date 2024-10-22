# Data source: AWS Partition
# Ce bloc de données permet de récupérer des informations sur la partition AWS dans laquelle Terraform fonctionne.
# Une partition AWS représente une région globale comme aws (régions publiques), aws-cn (Chine), ou aws-us-gov (Gouvernement des États-Unis).
data "aws_partition" "current" {}

# Resource: AWS IAM OpenID Connect (OIDC) Provider
# Doc : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider 
# Exemple : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
# Ce bloc crée un fournisseur OIDC dans AWS IAM, utilisé pour connecter Kubernetes à AWS via IRSA (IAM Roles for Service Accounts).
# Ce fournisseur permet à EKS d'utiliser des jetons OIDC pour authentifier les pods et leur attribuer des rôles IAM.
resource "aws_iam_openid_connect_provider" "oidc_provider" {

  # client_id_list définit les clients autorisés à interagir avec ce fournisseur OIDC.
  # Ici, il utilise le service STS (Security Token Service) pour l'authentification, qui dépend du suffixe DNS de la 
  # partition AWS (comme amazonaws.com pour les régions publiques).
  # Un truc comme sts.amazonaws.xxx.com (ie des clients sts amazon)
  client_id_list = ["sts.${data.aws_partition.current.dns_suffix}"]

  # thumbprint_list est la liste des empreintes numériques des certificats racines (CA) utilisés 
  # pour sécuriser les communications OIDC.
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]

  # url correspond à l'URL du fournisseur OIDC de ton cluster EKS, qui est récupérée depuis l'identité du cluster EKS.
  # Cela permet de lier le cluster EKS à ce fournisseur OIDC.
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  # Ajoute des balises (tags) à la ressource OIDC pour une gestion plus facile dans AWS.
  # Le nom du tag inclut le nom du cluster, et d'autres balises communes (maps) sont fusionnées 
  # à l'aide de la fonction merge().
  tags = merge(
    {
      Name = "${var.cluster_name}-eks-irsa"
    },
    local.common_tags
  )
}

# Output: AWS IAM OpenID Connect Provider ARN
# Ce bloc output permet d'exporter l'ARN (Amazon Resource Name) du fournisseur OIDC nouvellement créé.
# Cela peut être utilisé par d'autres ressources ou scripts Terraform pour identifier ce fournisseur.
output "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
}

# Local variable: Extract OIDC Provider from ARN
# Cette variable locale extrait la partie "oidc-provider/" de l'ARN complet du fournisseur OIDC.
# Elle divise l'ARN avec "split()" et sélectionne la seconde partie après "oidc-provider/".
# Ceci est utilisé pour simplifier l'accès à l'identifiant OIDC du cluster.
locals {
  aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}

# Output: Extracted OIDC Provider
# Ce bloc output exporte l'ID du fournisseur OIDC extrait de l'ARN complet pour une utilisation dans d'autres configurations.
# Il affiche uniquement la partie intéressante de l'ARN pour faciliter la gestion.
output "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
  value       = local.aws_iam_oidc_connect_provider_extract_from_arn
}


# Sample Outputs for Reference
/*
aws_iam_openid_connect_provider_arn = "arn:aws:iam::180789647333:oidc-provider/oidc.eks.eu-west-3.amazonaws.com/id/A9DED4A4FA341C2A5D985A260650F232"
aws_iam_openid_connect_provider_extract_from_arn = "oidc.eks.eu-west-3.amazonaws.com/id/A9DED4A4FA341C2A5D985A260650F232"
*/