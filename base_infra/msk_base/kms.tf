resource "aws_kms_key" "msk_kms_key" {
  description             = "MSK KMS Key for ${var.msk_identifier}"
  policy                  = data.aws_iam_policy_document.msk_kms_key_policy.json
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = merge(var.tags, tomap({ "Name" = "${var.msk_identifier}-msk-key" }))
}

resource "aws_kms_alias" "msk_key_alias" {
  name          = "alias/${var.msk_identifier}-msk-key"
  target_key_id = aws_kms_key.msk_kms_key.key_id
}

data "aws_iam_policy_document" "msk_kms_key_policy" {
  statement {
    sid = "Enable IAM User Permissions"

    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = concat(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"], [])
    }
  }

  statement {
    sid = "Allow access for Key Administrators"

    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:TagResource",
      "kms:UntagResource",
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid = "Allow use of the key"

    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com", "logs.ap-southeast-2.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      values   = ["ap-southeast-2"]
      variable = "aws:RequestedRegion"
    }
  }

}
