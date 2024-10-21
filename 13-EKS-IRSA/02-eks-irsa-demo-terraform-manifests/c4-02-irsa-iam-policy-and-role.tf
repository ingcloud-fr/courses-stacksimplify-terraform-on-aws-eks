#data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn
#data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn

# Resource: Création du rôle IAM et association d'une politique IAM EBS (IAM Role for IRSA)
# Ce bloc définit un rôle IAM spécifique pour l'IRSA (IAM Roles for Service Accounts) dans Kubernetes.
# Ce rôle sera assumé par des pods Kubernetes via un service account configuré.
resource "aws_iam_role" "irsa_iam_role" {
  name = "${local.name}-irsa-iam-role"  # Le nom du rôle IAM, basé sur une variable locale.

  # Le bloc assume_role_policy détermine quelles entités peuvent assumer ce rôle.
  # La fonction jsonencode convertit les données Terraform en format JSON valide.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"  # La version de la politique IAM.

    # Déclaration des actions autorisées pour ce rôle (STS Assume Role avec OIDC)
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"  # Cette action permet aux pods de Kubernetes d'assumer le rôle via un jeton OIDC.
        Effect = "Allow"  # Indique que l'action est autorisée.
        Sid    = ""  # Le Sid (Statement ID) est optionnel et vide ici.

        # Le principal (entité qui peut assumer ce rôle) est le fournisseur OIDC.
        Principal = {
          Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"  # Récupère l'ARN du fournisseur OIDC depuis l'état distant Terraform.
        }

        # Condition pour restreindre l'usage du rôle aux pods spécifiques
        Condition = {
          StringEquals = {
            # Associe ce rôle uniquement aux pods utilisant le service account "irsa-demo-sa" dans le namespace "default".
            # La clé ici est l'ARN extrait du fournisseur OIDC.
            "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:default:irsa-demo-sa"
          }
        }

      },
    ]
  })

  # Balises (tags) pour identifier le rôle IAM dans AWS
  tags = {
    tag-key = "${local.name}-irsa-iam-role"  # Tag qui suit le nom du rôle pour faciliter son identification dans AWS.
  }
}

# Resource: Attachement de la politique IAM au rôle IAM
# Ce bloc attache une politique IAM à un rôle IAM. Dans cet exemple, la politique permet un accès en lecture seule à S3.
resource "aws_iam_role_policy_attachment" "irsa_iam_role_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  # Politique Amazon S3 en lecture seule pour ce rôle.
  role       = aws_iam_role.irsa_iam_role.name  # Associe la politique au rôle IAM créé plus haut.
}

# Output: Exporte l'ARN du rôle IAM créé
# Le bloc output permet d'exporter l'ARN du rôle IAM pour une utilisation ultérieure dans d'autres modules ou scripts.
output "irsa_iam_role_arn" {
  description = "IRSA Demo IAM Role ARN"  # Description du rôle exporté.
  value       = aws_iam_role.irsa_iam_role.arn  # La valeur exportée est l'ARN du rôle IAM.
}



