output "msk_cluster_name" {
  description = "Name of the MSK cluster (empty string when MSK is not created)"
  value       = var.msk.create ? aws_msk_cluster.main[0].cluster_name : ""
}

output "msk_cluster_arn" {
  description = "ARN of the MSK cluster (null when MSK is not created)"
  value       = var.msk.create ? aws_msk_cluster.main[0].arn : null
}
