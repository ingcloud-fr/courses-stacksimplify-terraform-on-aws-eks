# EKS Cluster Input Variables
# Définit ici car necessaire dans les tags VPC, même si on ne le crée pas ici
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = "eksdemo"
}
