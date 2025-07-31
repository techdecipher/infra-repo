output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "ecr_repo_url" {
  value = aws_ecr_repository.flask_app.repository_url
}

