resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn = var.metadata_sqs_arn
  function_name    = var.metadata_function_arn
  batch_size       = 10

  scaling_config {
    maximum_concurrency = 100
  }
}

resource "aws_iam_policy" "metadata_function_policy" {
  name        = "metadata_lambda_policy"
  path        = "/"
  description = "Metadata lambda policy"

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
          "dynamodb:PutItem",
        ]
        Effect   = "Allow"
        Resource = var.dynamo_table_arn
      },
      {
        Action = [
          "sns:Publish",
        ]
        Effect   = "Allow"
        Resource = var.sns_arn
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Effect   = "Allow"
        Resource = var.metadata_sqs_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "metadata_function_attach" {
  role       = var.metadata_role_name
  policy_arn = aws_iam_policy.metadata_function_policy.arn
}