output "ec2_public_ip" {
  value = aws_instance.flask_server.public_ip
}

output "ecr_repo_url" {
  value = aws_ecr_repository.flask_repo.repository_url
}
