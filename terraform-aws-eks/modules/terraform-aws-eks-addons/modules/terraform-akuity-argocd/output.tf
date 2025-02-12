output "name" {
  description = "The Akuity cluster name"
  value       = try(akp_cluster.managed_cluster[0].name, null)
}

output "version" {
  description = "The Akuity ArgoCD version"
  value       = try(akp_cluster.managed_cluster[0].spec.data.target_version, null)
}

output "namespace" {
  description = "The Akuity installation namespace"
  value       = try(akp_cluster.managed_cluster[0].spec.data.target_version, null)
}
