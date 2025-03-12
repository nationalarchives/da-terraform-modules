output "repository_url" {
  description = "URL or the ECR repository"
  value       = aws_ecr_repository.repository.repository_url
}
