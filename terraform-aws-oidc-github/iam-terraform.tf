data "aws_iam_policy_document" "terraform" {
  count = var.attach_terraform_policy ? 1 : 0

  statement {
    sid    = "TFListStateBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.state_bucket_name}",
    ]
  }

  statement {
    sid    = "TFStateObjects"
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${local.state_bucket_name}",
      "arn:aws:s3:::${local.state_bucket_name}/*",
    ]
  }

  statement {
    sid    = "KMSPermissions"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AssumeRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = local.assumed_roles
  }
}

locals {
  account_ids = data.aws_organizations_organization.current.accounts[*].id
  assumed_roles = concat(
    [for account_id in local.account_ids : "arn:aws:iam::${account_id}:role/${local.tf_crossaccount_role}"],
    concat([
      for role in local.tf_extra_roles :
      [for account_id in local.account_ids : "arn:aws:iam::${account_id}:role/${role}"]
    ])
  )
}

resource "aws_iam_policy" "terraform" {
  count  = var.attach_terraform_policy ? 1 : 0
  name   = "terraformAutomation"
  path   = "/"
  policy = data.aws_iam_policy_document.terraform[0].json
}

resource "aws_iam_role_policy_attachment" "terraform" {
  count = var.attach_terraform_policy ? 1 : 0

  policy_arn = aws_iam_policy.terraform[0].arn
  role       = aws_iam_role.github.id
}
