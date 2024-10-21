resource "local_file" "output_file" {
  filename = "${path.module}/terraform-outputs.txt" # Chemin où le fichier sera créé
  content  = <<EOT
  Instance Bastion Public IP: ${aws_eip.bastion_eip.public_ip}
  Cluster Name: ${aws_eks_cluster.eks_cluster.name}
  Cluster API : ${aws_eks_cluster.eks_cluster.endpoint}
  EOT
}