# Re-exported for the after_apply checks in .spacelift/config.yml.
output "ecr_backend_repository_url" {
  value = module.spacelift_eks_selfhosted.ecr_backend_repository_url
}

output "ecr_launcher_repository_url" {
  value = module.spacelift_eks_selfhosted.ecr_launcher_repository_url
}

output "shell" {
  value     = module.spacelift_eks_selfhosted.shell
  sensitive = true
}

output "helm_values" {
  value = module.spacelift_eks_selfhosted.helm_values
}

output "kubernetes_secrets" {
  value     = module.spacelift_eks_selfhosted.kubernetes_secrets
  sensitive = true
}
