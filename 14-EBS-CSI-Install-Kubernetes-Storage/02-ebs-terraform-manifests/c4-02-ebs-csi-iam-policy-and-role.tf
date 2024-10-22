# Data source: Références aux outputs de l'état distant Terraform EKS
# Ces lignes de commentaires font référence à l'utilisation d'outputs provenant de l'état distant de Terraform pour récupérer des informations
# sur le fournisseur OIDC (OpenID Connect) du cluster EKS. Ces outputs sont utilisés pour créer un rôle IAM.
#data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn
#data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn

# Resource: Création de la politique IAM pour le pilote CSI EBS (EBS CSI IAM Policy)
# Ce bloc crée une politique IAM spécifiquement pour le pilote CSI (Container Storage Interface) EBS dans EKS.
# Le pilote CSI EBS permet à Kubernetes de gérer le stockage persistant via des volumes EBS (Elastic Block Store).
resource "aws_iam_policy" "ebs_csi_iam_policy" {
  name        = "${local.name}-AmazonEKS_EBS_CSI_Driver_Policy" # Nom de la politique IAM.
  path        = "/"                                             # Chemin par défaut pour la politique IAM.
  description = "EBS CSI IAM Policy"                            # Description pour la politique IAM.

  # Récupère le contenu de la politique IAM depuis une source HTTP dans c4-01.
  # La politique elle-même est chargée depuis une URL spécifiée (via data.http).
  policy = data.http.ebs_csi_iam_policy.response_body
}

# Output: ARN de la politique IAM pour EBS CSI
# Ce bloc output exporte l'ARN de la politique IAM nouvellement créée, ce qui permet de la référencer dans d'autres ressources ou modules.
output "ebs_csi_iam_policy_arn" {
  value = aws_iam_policy.ebs_csi_iam_policy.arn # Exporte l'ARN de la politique IAM.
}

# Resource: Création du rôle IAM pour le pilote EBS CSI et association de la politique
# Ce bloc crée un rôle IAM qui sera utilisé par le pilote EBS CSI via IRSA (IAM Roles for Service Accounts).
resource "aws_iam_role" "ebs_csi_iam_role" {
  name = "${local.name}-ebs-csi-iam-role" # Nom du rôle IAM créé pour le pilote EBS CSI.

  # La fonction "jsonencode" permet de convertir une expression Terraform en syntaxe JSON valide pour la politique IAM.
  assume_role_policy = jsonencode({
    Version = "2012-10-17" # Version de la politique IAM.
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity" # Action permettant aux pods de Kubernetes d'assumer ce rôle via un jeton OIDC.
        Effect = "Allow"                         # Indique que cette action est autorisée.
        Sid    = ""                              # Statement ID, optionnel et laissé vide ici.

        # Déclaration du principal, ici un fournisseur OIDC (OpenID Connect).
        Principal = {
          Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}" # ARN du fournisseur OIDC récupéré depuis l'état distant de Terraform.
        }

        # Conditions pour restreindre l'usage de ce rôle aux pods spécifiques dans Kubernetes.
        Condition = {
          StringEquals = {
            # Associe ce rôle uniquement au service account "ebs-csi-controller-sa" dans le namespace "kube-system".
            # L'ARN du fournisseur OIDC est récupéré depuis l'état distant Terraform.
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      },
    ]
  })

  # Balises (tags) pour identifier le rôle IAM dans AWS.
  tags = {
    tag-key = "${local.name}-ebs-csi-iam-role" # Tag personnalisé basé sur une variable locale pour identifier ce rôle IAM.
  }
}

# Resource: Association de la politique IAM avec le rôle IAM du pilote EBS CSI
# Ce bloc attache la politique IAM créée plus haut au rôle IAM, permettant à ce rôle d'avoir les permissions définies dans la politique.
resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.ebs_csi_iam_policy.arn # ARN de la politique IAM à attacher.
  role       = aws_iam_role.ebs_csi_iam_role.name    # Nom du rôle IAM auquel attacher la politique.
}

# Output: ARN du rôle IAM pour EBS CSI
# Ce bloc output exporte l'ARN du rôle IAM nouvellement créé pour le pilote EBS CSI.
# Cet ARN peut être utilisé pour identifier le rôle dans d'autres configurations ou scripts.
output "ebs_csi_iam_role_arn" {
  description = "EBS CSI IAM Role ARN"            # Description pour l'output.
  value       = aws_iam_role.ebs_csi_iam_role.arn # Exporte l'ARN du rôle IAM.
}
