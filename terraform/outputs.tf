output "vpc_id" {
  value = module.vpc.vpc_id
}
output "ecr_repository_url" {
  value = module.aws_ecr_repository.repository_url
}