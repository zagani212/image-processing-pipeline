resource "aws_lambda_event_source_mapping" "thumbnail_event_source" {
  event_source_arn = var.thumbnail_sqs_arn
  function_name    = var.thumbnail_function_arn
  batch_size       = 10

  scaling_config {
    maximum_concurrency = 100
  }
}

resource "aws_iam_policy" "thumbnail_function_policy" {
  name        = "thumbnail_lambda_policy"
  path        = "/"
  description = "Thumbnail resize lambda policy"

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
        Resource = [format("%s/uploads/*", var.bucket_arn), format("%s/thumbnails/*", var.bucket_arn)]
      },
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = format("%s/thumbnails/*", var.bucket_arn)
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
        ]
        Effect   = "Allow"
        Resource = var.thumbnail_sqs_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "thumbnail_function_attach" {
  role       = var.thumbnail_role_name
  policy_arn = aws_iam_policy.thumbnail_function_policy.arn
}