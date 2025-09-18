data "aws_eks_cluster" "this" {
  name = var.cluster_name
}
data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

locals {
  cluster_oidc_issuer_url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  iam_idp_provider_arn    = data.aws_iam_openid_connect_provider.this.arn
}


# Creates an IAM role for a service account in EKS

# trust policy, restricts use of the role to the service account inside the kubernetes cluster
data "aws_iam_policy_document" "trust-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.iam_idp_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = replace("${local.cluster_oidc_issuer_url}:sub", "https://", "")
      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account}"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = replace("${local.cluster_oidc_issuer_url}:aud", "https://", "")
      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

# iam role
resource "aws_iam_role" "role" {
  name               = "${var.cluster_name}-${var.namespace}-${var.service_account}"
  description        = "Role for ${var.namespace}/${var.service_account} in cluster ${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.trust-policy.json
}

# iam policy attached to the role, the policy document comes from the code calling this module
resource "aws_iam_role_policy" "policy" {
  count  = length(var.policy_statements) > 0 ? 1 : 0
  name   = "${var.cluster_name}-${var.namespace}-${var.service_account}"
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.this.json
}


data "aws_iam_policy_document" "this" {

  dynamic "statement" {
    for_each = var.policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "kubernetes_service_account_v1" "this" {
  count = var.create_sa ? 1 : 0
  metadata {
    name      = var.service_account
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.role.arn
    }
  }

  automount_service_account_token = true
}
