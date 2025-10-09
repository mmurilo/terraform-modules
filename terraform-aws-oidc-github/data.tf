data "aws_partition" "current" {}

data "aws_organizations_organization" "current" {}

data "aws_iam_policy_document" "assume_role" {

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    sid     = "GitHubOIDCAssumeRole"

    # Primary security condition: Restrict to specific GitHub repositories
    # Supports both specific refs (owner/repo:ref:refs/heads/main) and wildcards (owner/repo:*)
    condition {
      test = "StringLike"
      values = [
        for repo in var.github_repositories :
        "repo:%{if length(regexall(":+", repo)) > 0}${repo}%{else}${repo}:*%{endif}"
      ]
      variable = "token.actions.githubusercontent.com:sub"
    }

    # Audience validation: Ensure token is intended for AWS STS
    condition {
      test = "StringEquals"
      values = [
        "sts.amazonaws.com"
      ]
      variable = "token.actions.githubusercontent.com:aud"
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }

  version = "2012-10-17"
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1

  url = local.github_actions_oidc_url
}
