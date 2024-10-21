cluster_name = "eksdemo1"
# Spécifie le CIDR IPv4 utilisé pour les services Kubernetes au sein du cluster.
cluster_service_ipv4_cidr = "172.20.0.0/16"
# cluster_version = "1.28" # # derniere version support étendu
cluster_version                 = "1.31" # derniere version support standard
cluster_endpoint_private_access = false
cluster_endpoint_public_access  = true # Pour Groupe nodes publics et Kubectl local
# Définit les plages CIDR autorisées à accéder à l'API publique du cluster si activée.
# On peut passer à mon ip locale pour connection via kubectl
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

