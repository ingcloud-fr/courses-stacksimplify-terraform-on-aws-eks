# Création du cluster AWS EKS
# Documentation : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

resource "aws_eks_cluster" "eks_cluster" {
  # Définition du nom du cluster EKS
  name = "${local.name}-${var.cluster_name}"
  ##name = local.eks_cluster_name

  # Le rôle IAM assigné au cluster EKS pour permettre au plan de contrôle (Control Plane) de gérer les ressources AWS.
  role_arn = aws_iam_role.eks_master_role.arn

  # Spécifie la version de Kubernetes à utiliser pour ce cluster EKS. Cela doit être géré pour correspondre à la version supportée par EKS.
  version = var.cluster_version

  # Configuration du réseau VPC du cluster EKS
  vpc_config {
    # Spécifie les sous-réseaux publics dans lesquels les nœuds EKS seront déployés.
    # Ex: subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id]
    subnet_ids = module.vpc.public_subnets

    # Spécifie si l'accès privé à l'API du cluster (via des sous-réseaux privés) est activé. Dans ce projet, cette option est désactivée (False).
    endpoint_private_access = var.cluster_endpoint_private_access

    # Spécifie si l'accès public à l'API du cluster (via des sous-réseaux publics) est activé. Dans ce projet, cette option est activée (True).
    endpoint_public_access = var.cluster_endpoint_public_access

    # Définit les plages CIDR autorisées à accéder à l'API publique du cluster. Cela permet de restreindre l'accès à certaines adresses IP ou plages d'adresses.
    public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  }

  # Configuration du réseau Kubernetes du cluster EKS (optionnel)
  kubernetes_network_config {
    # Spécifie le CIDR IPv4 utilisé pour les services Kubernetes au sein du cluster.
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  # Activation des logs du Control Plane du cluster EKS
  # Cela permet de suivre les événements importants au niveau de l'API du cluster, l'authentification, l'audit et la planification des pods.
  # On les mets tous : api, audit, authenticator, controllerManager, scheduler
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ajout des balises
  tags = {
    Name        = local.eks_cluster_name
    Environment = var.environment
  }

  # Le bloc `depends_on` assure que les ressources IAM (politiques et rôles) sont créées avant la création du cluster EKS.
  # Sans cela, EKS pourrait rencontrer des erreurs lors de la gestion de l'infrastructure sous-jacente (comme les groupes de sécurité).
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,         # Politique nécessaire pour permettre à EKS de gérer le cluster.
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController, # Politique nécessaire pour gérer les ressources VPC associées.
  ]
}
