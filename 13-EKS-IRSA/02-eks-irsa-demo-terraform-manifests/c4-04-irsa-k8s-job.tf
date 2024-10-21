# Resource: Kubernetes Job
# Ce bloc définit un **Job Kubernetes** qui est une ressource utilisée pour exécuter une tâche unique ou répétée de manière 
# contrôlée dans un cluster.
# Un Job crée un ou plusieurs pods pour exécuter une tâche, et garantit que la tâche est terminée avec succès. 
# Doc : https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job_v1 
resource "kubernetes_job_v1" "irsa_demo" {

  # Métadonnées pour le Job Kubernetes.
  metadata {
    name = "irsa-demo"  # Le nom du Job, ici "irsa-demo".
  }

  # Spécifications du Job
  spec {

    # Template qui décrit le pod à créer pour exécuter le Job.
    template {
      metadata {
        # Ajout de labels au pod pour permettre de l'identifier ou de le sélectionner.
        labels = {
          app = "irsa-demo"  # Label pour identifier le pod associé à ce Job.
        }
      }

      # Spécifications des conteneurs à l'intérieur du pod créé par le Job.
      spec {
        # Le service account qui sera utilisé par le pod, ici associé au compte de service IRSA.
        # Ce service account permet d'associer le pod à un rôle IAM qui lui donne des permissions AWS spécifiques.
        service_account_name = kubernetes_service_account_v1.irsa_demo_sa.metadata.0.name # crée dans c403

        # Définition du conteneur dans lequel le Job sera exécuté.
        container {
          name  = "irsa-demo"  # Nom du conteneur.
          image = "amazon/aws-cli:latest"  # Image Docker utilisée par le pod, ici l'image AWS CLI pour interagir avec les services AWS.

          # Arguments passés au conteneur, ici pour lister les objets dans un bucket S3 en utilisant la commande AWS CLI.
          args  = ["s3", "ls"]

          # Exemple commenté d'un autre argument pour décrire les instances EC2. Cette commande échouerait ici
          # car le rôle IAM associé au service account n'a pas les permissions nécessaires pour accéder à EC2.
          #args = ["ec2", "describe-instances", "--region", "${var.aws_region}"] # Devrait échouer car nous n'avons pas les permissions EC2
        }

        # Politique de redémarrage du Job. Ici, le Job ne doit **pas** redémarrer en cas d'échec, car la tâche est exécutée une seule fois.
        restart_policy = "Never"
      }
    }
  }
}
