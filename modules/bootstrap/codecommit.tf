resource "aws_codecommit_repository" "infrastructure_repository" {
  repository_name = var.infrastructure_repository_name
  description     = "Infrastructure Repository"
}
