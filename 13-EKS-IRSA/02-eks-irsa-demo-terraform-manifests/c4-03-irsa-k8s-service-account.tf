# Resource: Kubernetes Service Account
# Ce bloc crée un compte de service (service account) Kubernetes qui sera utilisé par des pods dans le cluster EKS.
# Ce service account est lié à un rôle IAM spécifique via IRSA (IAM Roles for Service Accounts), ce qui permet aux pods d'assumer le rôle IAM
# et d'utiliser ses permissions pour accéder aux services AWS (comme S3, DynamoDB, etc.).

resource "kubernetes_service_account_v1" "irsa_demo_sa" {

  # "depends_on" assure que cette ressource ne sera créée qu'après l'attachement de la politique IAM au rôle IAM.
  # Cela garantit que le rôle IAM avec les permissions AWS nécessaires est bien configuré avant de créer ce service account.
  depends_on = [aws_iam_role_policy_attachment.irsa_iam_role_policy_attach]

  # Métadonnées du service account Kubernetes.
  metadata {
    # Le nom du service account dans Kubernetes, qui sera référencé par les pods souhaitant utiliser ce compte.
    name = "irsa-demo-sa"

    # Annotations pour associer ce service account à un rôle IAM via IRSA.
    # L'annotation "eks.amazonaws.com/role-arn" est spécifique à EKS et indique le rôle IAM que les pods utilisant ce 
    # service account peuvent assumer.
    # Ici, on utilise l'ARN du rôle IAM précédemment défini dans une autre ressource Terraform.
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa_iam_role.arn  # Associe ce service account au rôle IAM via son ARN.
    }
  }
}
