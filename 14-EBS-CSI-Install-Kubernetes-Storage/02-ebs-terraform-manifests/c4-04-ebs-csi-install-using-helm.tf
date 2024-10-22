# Installer le pilote EBS CSI en utilisant HELM
# Resource: Déploiement d'un Chart Helm avec Terraform
# Doc : https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release

resource "helm_release" "ebs_csi_driver" {
  # La directive "depends_on" garantit que cette ressource ne sera créée qu'après la création du rôle IAM associé.
  # Cela assure que le rôle IAM (et ses permissions) est en place avant l'installation du pilote EBS CSI.
  depends_on = [aws_iam_role.ebs_csi_iam_role]

  # Nom de la release Helm. Ici, il est défini dynamiquement à l'aide d'une variable locale (local.name).
  name       = "${local.name}-aws-ebs-csi-driver"

  # URL du dépôt contenant le chart Helm du pilote EBS CSI. Ce dépôt est maintenu par Kubernetes SIGs (Special Interest Groups).
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"

  # Nom du chart Helm à installer depuis le dépôt.
  chart      = "aws-ebs-csi-driver"

  # Namespace Kubernetes dans lequel le pilote sera installé. "kube-system" est un namespace par défaut pour les composants systèmes de Kubernetes.
  namespace  = "kube-system"

  # Configuration des paramètres du chart Helm
  set {
    # Définir l'image Docker utilisée par le pilote EBS CSI. L'image est hébergée dans le registre ECR d'AWS et doit être adaptée en fonction de la région AWS.
    # Ici, l'image spécifiée est celle pour la région "eu-west-3" (Paris). Cette valeur doit être changée selon la région dans laquelle le cluster est déployé.
    # Référence additionnelle pour les images : https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
    name  = "image.repository"
    value = "602401143452.dkr.ecr.eu-west-3.amazonaws.com/eks/aws-ebs-csi-driver"
  }

  # Indique au chart Helm de créer un compte de service (Service Account) pour le contrôleur EBS CSI.
  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  # Définir le nom du service account à utiliser pour le contrôleur EBS CSI.
  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  # Annotation pour lier le service account Kubernetes au rôle IAM créé via IRSA.
  # Cette annotation est spécifique à EKS et lie le service account au rôle IAM pour que les pods puissent assumer ce rôle et utiliser ses permissions.
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.ebs_csi_iam_role.arn
  }
}
