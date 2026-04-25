resource "aws_lambda_event_source_mapping" "medium_event_source" {
  event_source_arn = var.medium_sqs_arn
  function_name    = var.medium_function_arn
  batch_size       = 10

  scaling_config {
    maximum_concurrency = 100
  }
}

resource "aws_iam_policy" "medium_function_policy" {
  name        = "medium_lambda_policy"
  path        = "/"
  description = "Medium resize lambda policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = format("%s/uploads/*", var.bucket_arn)
      },
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = format("%s/mediums/*", var.bucket_arn)
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Effect   = "Allow"
        Resource = var.medium_sqs_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "medium_function_attach" {
  role       = var.medium_role_name
  policy_arn = aws_iam_policy.medium_function_policy.arn
}