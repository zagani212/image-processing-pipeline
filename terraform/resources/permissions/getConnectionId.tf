resource "aws_lambda_permission" "get_connection_id_handler_function_allow_api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.get_connection_id_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = format("%s/*/*", var.api_gw_ws )
}

resource "aws_iam_policy" "get_connection_id_handler_function_policy" {
  name        = "get_connection_id_handler_lambda_policy"
  path        = "/"
  description = "Validate lambda policy"

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
    ]
  })
}

resource "aws_iam_role_policy_attachment" "get_connection_id_handler_function_attach" {
  role       = var.get_connection_id_handler_role_name
  policy_arn = aws_iam_policy.get_connection_id_handler_function_policy.arn
}