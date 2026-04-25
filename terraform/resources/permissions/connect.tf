resource "aws_lambda_permission" "connect_handler_function_allow_api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.connect_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = format("%s/*/*", var.api_gw_ws )
}