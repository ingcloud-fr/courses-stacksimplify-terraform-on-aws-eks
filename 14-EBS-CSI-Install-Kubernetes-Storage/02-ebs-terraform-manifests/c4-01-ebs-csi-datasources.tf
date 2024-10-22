# Datasource: Récupération de la politique IAM pour le pilote EBS CSI depuis le dépôt Git officiel
# Ce bloc de données utilise le fournisseur HTTP de Terraform pour récupérer une ressource en ligne.
# Il télécharge le fichier JSON contenant la politique IAM pour le pilote EBS CSI (Container Storage Interface),
# directement depuis le dépôt GitHub officiel de Kubernetes.
data "http" "ebs_csi_iam_policy" {
  # URL du fichier contenant la politique IAM pour le pilote EBS CSI.
  # Ce fichier JSON définit les permissions nécessaires pour le bon fonctionnement du pilote.
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"

  # Headers de requête facultatifs envoyés avec la demande HTTP.
  # Ici, le header "Accept" indique que nous voulons obtenir une réponse au format JSON.
  request_headers = {
    Accept = "application/json"
  }
}

# Output: Exporter le contenu de la politique IAM téléchargée
# Ce bloc output permet d'exposer le contenu de la politique IAM téléchargée à partir du dépôt GitHub.
# Cela facilite l'utilisation de cette politique dans d'autres parties du code Terraform.
output "ebs_csi_iam_policy" {
  # La valeur de l'output est le corps de la réponse HTTP, qui contient le contenu JSON de la politique IAM.
  # On utilise "response_body" pour récupérer le texte brut de la politique JSON.
  value = data.http.ebs_csi_iam_policy.response_body
}
