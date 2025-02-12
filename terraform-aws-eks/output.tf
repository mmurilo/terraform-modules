############################################
# EKS
############################################

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = module.eks.cluster_version
}

output "eks" {
  description = "outputs from EKS module"
  value       = module.eks
}

############################################
# IRSA
############################################

output "vpc_cni_irsa_role" {
  description = "outputs from vpc_cni_irsa_role module"
  value       = module.vpc_cni_irsa_role
}

output "ebs_csi_irsa_role" {
  description = "outputs from ebs_csi_irsa_role module"
  value       = module.ebs_csi_irsa_role
}

# output "efs_csi_irsa_role" {
#   description = "outputs from efs_csi_irsa_role module"
#   value       = module.efs_csi_irsa_role
# }

output "cloudwatch_irsa_role" {
  description = "outputs from cloudwatch_irsa_role module"
  value       = module.cloudwatch_irsa_role
}

############################################
# Addons 
############################################

output "cluster_addons" {
  description = "outputs from EKS addons module"
  value       = module.eks_cluster_addons
}
