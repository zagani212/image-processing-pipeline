data "aws_iam_policy_document" "allow_sns_medium_sqs" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [var.medium_sqs_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sns_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "medium_sqs_policy" {
  queue_url = var.medium_sqs_url
  policy    = data.aws_iam_policy_document.allow_sns_medium_sqs.json
}

#####

data "aws_iam_policy_document" "allow_sns_thumbnail_sqs" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [var.thumbnail_sqs_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sns_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "thumbnail_sqs_policy" {
  queue_url = var.thumbnail_sqs_url
  policy    = data.aws_iam_policy_document.allow_sns_thumbnail_sqs.json
}

#####

data "aws_iam_policy_document" "allow_sns_watermark_sqs" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [var.watermark_sqs_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sns_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "watermark_sqs_policy" {
  queue_url = var.watermark_sqs_url
  policy    = data.aws_iam_policy_document.allow_sns_watermark_sqs.json
}