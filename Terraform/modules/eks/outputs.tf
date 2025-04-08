output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}
output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}
output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value = aws_iam_role.github_actions.arn
}