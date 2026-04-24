resource "aws_lambda_permission" "validate_function_allow_api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.validate_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = format("%s/*/*", var.api_gw )
}