locals {
  tags                          = var.tags
  oidc_provider_arn             = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
  partition                     = data.aws_partition.current.partition
  thumbprint_list               = var.thumbprint != null ? [var.thumbprint] : []
  github_actions_oidc_url       = var.github_actions_oidc_url
  force_detach_policies         = var.force_detach_policies
  max_session_duration          = var.max_session_duration
  iam_role_name                 = var.iam_role_name
  iam_role_path                 = var.iam_role_path
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_inline_policies      = var.iam_role_inline_policies
  iam_role_policy_arns          = toset(var.iam_role_policy_arns)
  tf_crossaccount_role          = var.tf_crossaccount_role
  tf_extra_roles                = var.tf_extra_roles
  state_bucket_name             = var.state_bucket_name
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  # GitHub Actions OIDC only uses sts.amazonaws.com as the audience
  # See: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
  client_id_list = ["sts.amazonaws.com"]

  tags            = try(local.tags, null)
  thumbprint_list = length(local.thumbprint_list) > 0 ? local.thumbprint_list : null
  url             = local.github_actions_oidc_url
}


resource "aws_iam_role" "github" {

  assume_role_policy    = data.aws_iam_policy_document.assume_role.json
  description           = "Role assumed by the GitHub OIDC provider."
  force_detach_policies = local.force_detach_policies
  max_session_duration  = local.max_session_duration
  name                  = local.iam_role_name
  path                  = local.iam_role_path
  permissions_boundary  = local.iam_role_permissions_boundary
  tags                  = try(local.tags, null)

  dynamic "inline_policy" {
    for_each = local.iam_role_inline_policies

    content {
      name   = inline_policy.key
      policy = inline_policy.value
    }
  }
}

resource "aws_iam_role_policy_attachment" "read_only" {
  count = var.attach_read_only_policy ? 1 : 0

  policy_arn = "arn:${local.partition}:iam::aws:policy/ReadOnlyAccess"
  role       = aws_iam_role.github.id
}

resource "aws_iam_role_policy_attachment" "custom" {
  for_each = local.iam_role_policy_arns

  policy_arn = each.key
  role       = aws_iam_role.github.id
}

resource "aws_iam_role_policy_attachment" "admin" {
  count = var.attach_admin_policy ? 1 : 0

  policy_arn = "arn:${local.partition}:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.github.id
}
