# Déploiement Kubernetes (Deployment Resource)
# Ce bloc définit un objet Kubernetes "Deployment", qui permet de gérer un ensemble de Pods réplicables pour l'application "myapp1".
resource "kubernetes_deployment_v1" "myapp1" {

  # Métadonnées pour le déploiement
  # Ces informations incluent le nom du déploiement et un label pour identifier l'application.
  metadata {
    name = "myapp1-deployment"  # Nom du déploiement
    labels = {
      app = "myapp1"  # Label pour identifier l'application
    }
  }

  # Spécification du déploiement
  spec {
    replicas = 4  # Le nombre de Pods que le déploiement doit créer (2 réplicas)

    # Sélecteur de Pods
    # Ce sélecteur garantit que les Pods créés ont un label correspondant à "app=myapp1".
    selector {
      match_labels = {
        app = "myapp1"  # Le label à utiliser pour faire correspondre les Pods gérés par ce déploiement
      }
    }

    # Modèle pour les Pods (Pod Template)
    # Ce bloc définit les métadonnées et la spécification des conteneurs pour chaque Pod créé par ce déploiement.
    template {

      # Métadonnées du Pod
      # Les labels ici doivent correspondre à ceux du sélecteur pour que les Pods soient correctement associés au déploiement.
      metadata {
        labels = {
          app = "myapp1"  # Label pour les Pods créés par ce déploiement
        }
      }

      # Spécification des conteneurs du Pod
      # Ce bloc définit les conteneurs qui s'exécuteront dans chaque Pod créé.
      spec {

        # Définition du conteneur
        container {
          image = "stacksimplify/kubenginx:1.0.0"  # Image Docker à utiliser pour le conteneur
          name  = "myapp1-container"  # Nom du conteneur

          # Définition du port du conteneur
          port {
            container_port = 80  # Port exposé par le conteneur à l'intérieur du Pod
          }
        }
      }
    }
  }
}
