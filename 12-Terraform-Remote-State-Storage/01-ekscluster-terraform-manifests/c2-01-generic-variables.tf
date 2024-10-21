# Variables d'entrée pour la région AWS, l'environnement et la division métier

variable "aws_region" {
  description = "Région où les ressources AWS seront créées"
  type        = string
  default     = "eu-west-3" # Région par défaut
}

variable "environment" {
  description = "Nom de l'environnement (dev, stag, prod)"
  type        = string
  default     = "dev"
}

variable "business_divsion" {
  description = "Division métier dans une grande organisation"
  type        = string
  default     = "SAP"
}
