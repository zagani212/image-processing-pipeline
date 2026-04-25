resource "aws_lambda_event_source_mapping" "watermark_event_source" {
  event_source_arn = var.watermark_sqs_arn
  function_name    = var.watermark_function_arn
  batch_size       = 10

  scaling_config {
    maximum_concurrency = 100
  }
}

resource "aws_iam_policy" "watermark_function_policy" {
  name        = "watermark_lambda_policy"
  path        = "/"
  description = "Watermark lambda policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "execute-api:ManageConnections"
        ]
        Effect   = "Allow"
        Resource = ["${var.api_gw_ws}/*/*/@connections/*"]
      },
      {
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = [format("%s/uploads/*", var.bucket_arn), format("%s/watermarked/*", var.bucket_arn)]
      },
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = format("%s/watermarked/*", var.bucket_arn)
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Effect   = "Allow"
        Resource = var.watermark_sqs_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "watermark_function_attach" {
  role       = var.watermark_role_name
  policy_arn = aws_iam_policy.watermark_function_policy.arn
}