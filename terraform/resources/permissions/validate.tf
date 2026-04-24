resource "aws_lambda_permission" "validate_function_allow_api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.validate_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = format("%s/*/*", var.api_gw )
}

resource "aws_iam_policy" "validate_function_policy" {
  name        = "validate_lambda_policy"
  path        = "/"
  description = "Validate lambda policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = format("%s/uploads/*", var.bucket_arn)
      },
      {
        Action = [
          "sqs:SendMessage",
        ]
        Effect   = "Allow"
        Resource = var.metadata_sqs_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "validate_function_attach" {
  role       = var.validate_role_name
  policy_arn = aws_iam_policy.validate_function_policy.arn
}