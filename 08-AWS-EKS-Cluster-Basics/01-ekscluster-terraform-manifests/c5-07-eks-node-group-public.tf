# Création d'un groupe de nœuds EKS - Public
# Ce groupe de nœuds utilise les sous-réseaux publics du VPC et est associé au cluster EKS existant.
# Doc : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group

resource "aws_eks_node_group" "eks_ng_public" {
  # Le nom du cluster EKS auquel ce groupe de nœuds appartient.
  cluster_name = aws_eks_cluster.eks_cluster.name

  # Nom du groupe de nœuds, en utilisant une variable locale pour la personnalisation.
  node_group_name = "${local.name}-eks-ng-public"

  # Rôle IAM attribué aux instances EC2 dans ce groupe de nœuds.
  node_role_arn = aws_iam_role.eks_nodegroup_role.arn

  # Utilisation des sous-réseaux publics du VPC pour déployer les instances EC2 de ce groupe de nœuds.
  subnet_ids = module.vpc.public_subnets

  # Spécifie la version K8S à utiliser dans les Nodes Groups (optionnel)
  # Par défaut c'est la version du cluster
  # version = var.cluster_version

  # Type d'AMI utilisé pour les instances EC2 dans le groupe de nœuds.
  # Ici, Amazon Linux 2 (AL2) est utilisé pour des instances x86_64.
  # Les valeurs : https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html
  ami_type = "AL2_x86_64"

  # Type de capacité pour les instances EC2. Ici, des instances à la demande (ON_DEMAND) sont spécifiées.
  # Cela peut être remplacé par "SPOT" pour des instances Spot moins coûteuses.
  capacity_type = "ON_DEMAND"

  # Taille du disque EBS attaché aux instances EC2 (en Go).
  disk_size = 20

  # Types d'instances EC2 à utiliser. Ici, des instances t3.medium sont spécifiées pour un bon rapport qualité-prix.
  instance_types = ["t3.medium"]

  # Configuration de l'accès distant aux instances EC2 via SSH.
  remote_access {
    # Clé SSH pour accéder aux instances EC2. Elle doit être préalablement créée dans AWS.
    ec2_ssh_key = "eks-terraform-key"

    # Optionnel : spécification des groupes de sécurité pour l'accès SSH. Par défaut, cela autorise [0.0.0.0/0], ce qui est ouvert à tous.
    #source_security_group_ids = [] # Utiliser un groupe de sécurité personnalisé pour restreindre l'accès.
  }

  # Configuration de la scalabilité automatique du groupe de nœuds.
  scaling_config {
    # Taille désirée du groupe de nœuds (1 instance au départ).
    desired_size = 1

    # Nombre minimum d'instances EC2 dans le groupe de nœuds (minimum de 1).
    min_size = 1

    # Nombre maximum d'instances EC2 dans le groupe de nœuds (maximum de 2).
    max_size = 2
  }

  # Configuration des mises à jour du groupe de nœuds.
  update_config {
    # Nombre maximal de nœuds indisponibles lors des mises à jour.
    max_unavailable = 1

    # Optionnel : Pourcentage maximal de nœuds indisponibles lors des mises à jour.
    #max_unavailable_percentage = 50  # À utiliser si on préfère gérer en pourcentage.
  }

  # Dépendances : Assure que les politiques IAM nécessaires pour les nœuds sont créées avant la création du groupe de nœuds.
  # Cela garantit que les nœuds ont les permissions nécessaires pour accéder aux services AWS.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,          # Permet aux nœuds de communiquer avec le plan de contrôle EKS.
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,               # Permet aux nœuds de gérer les interfaces réseau et le réseau des pods.
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly, # Permet aux nœuds de tirer des images depuis Amazon ECR (registre d'images Docker).
  ]

  # Balise pour identifier ce groupe de nœuds comme étant un groupe public dans AWS.
  tags = {
    Name = "Public-Node-Group"
  }
}
