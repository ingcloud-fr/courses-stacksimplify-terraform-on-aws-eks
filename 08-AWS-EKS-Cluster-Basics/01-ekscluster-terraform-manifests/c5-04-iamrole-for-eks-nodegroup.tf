# Création d'un rôle IAM pour le groupe de nœuds EKS
# Ce rôle sera utilisé par les instances EC2 qui font partie du groupe de nœuds EKS.
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${local.name}-eks-nodegroup-role"

  # La politique assume_role_policy permet aux instances EC2 (spécifiées via 'ec2.amazonaws.com')
  # d'assumer ce rôle. Cela donne aux instances les permissions d'agir selon les politiques IAM associées.
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attache la politique 'AmazonEKSWorkerNodePolicy' au rôle IAM
# Cette politique donne aux nœuds EKS les permissions de communiquer avec le plan de contrôle EKS.
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

# Attache la politique 'AmazonEKS_CNI_Policy' au rôle IAM
# Cette politique permet la gestion du réseau pour les pods via le CNI (Container Network Interface) d'EKS.
resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

# Attache la politique 'AmazonEC2ContainerRegistryReadOnly' au rôle IAM
# Cette politique permet aux nœuds EC2 de tirer des images depuis le registre ECR en mode lecture seule.
resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}
