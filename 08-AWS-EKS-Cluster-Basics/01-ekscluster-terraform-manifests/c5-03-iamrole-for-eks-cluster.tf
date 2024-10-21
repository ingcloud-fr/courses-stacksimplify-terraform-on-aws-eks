# Crée un rôle IAM nommé "eks-master-role"
# Ce rôle sera utilisé par EKS pour créer et gérer des ressources.
resource "aws_iam_role" "eks_master_role" {
  name = "${local.name}-eks-master-role"

  # La politique assume_role_policy permet au service EKS d'assumer ce rôle.
  # Cela permet à EKS d'agir avec les permissions accordées à ce rôle.
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attache la politique AmazonEKSClusterPolicy au rôle IAM "eks_master_role".
# Cette politique donne les permissions nécessaires à EKS pour gérer le cluster EKS.
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

# Attache la politique AmazonEKSVPCResourceController au rôle IAM "eks_master_role".
# Cette politique est requise pour que le service EKS puisse gérer les ressources liées au VPC (comme les ENI).
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}

/*
# Optionnel : Activer les groupes de sécurité pour les pods
# Cela permet de restreindre les règles de réseau au niveau des pods dans Kubernetes,
# si l'option est activée pour ton cluster EKS.
# Référence : https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}
*/
