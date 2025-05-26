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
  value       = var.enable_vpc_cni ? module.vpc_cni_irsa_role[0] : null
}

output "ebs_csi_irsa_role" {
  description = "outputs from ebs_csi_irsa_role module"
  value       = var.enable_aws_ebs_csi_driver ? module.ebs_csi_irsa_role[0] : null
}

output "efs_csi_irsa_role" {
  description = "outputs from efs_csi_irsa_role module"
  value       = var.enable_aws_efs_csi_driver ? module.efs_csi_irsa_role[0] : null
}

output "cloudwatch_irsa_role" {
  description = "outputs from cloudwatch_irsa_role module"
  value       = var.enable_amazon_cloudwatch_observability ? module.cloudwatch_irsa_role[0] : null
}

# ############################################
# # Addons 
# ############################################

# output "cluster_addons" {
#   description = "outputs from EKS addons module"
#   value       = module.eks_cluster_addons
# }

output "subnet_ids" {
  description = "Node subnet ids"
  value       = var.subnet_ids
}

############################################
# IAM SSO Roles Data
############################################

output "admin_sso_role" {
  description = "IAM roles matching the AdminAccess pattern from AWS SSO"
  value       = tolist(data.aws_iam_roles.admin_sso_roles.arns)[0]
}
