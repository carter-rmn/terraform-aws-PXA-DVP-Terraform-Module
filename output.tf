output "cluster_endpoint" {
  value = var.eks.create ? aws_eks_cluster.eks[0].endpoint : null
}

output "cluster_certificate_authority_data" {
  value = var.eks.create ? aws_eks_cluster.eks[0].certificate_authority[0].data : null
}

output "cluster_name" {
  value = var.eks.create ? aws_eks_cluster.eks[0].name : null
}