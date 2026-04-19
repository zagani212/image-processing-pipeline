resource "aws_apigatewayv2_integration" "example" {
  api_id           = aws_apigatewayv2_api.api_gw.id
  integration_type = "AWS_PROXY"

  description               = "validate image"
  integration_method        = "POST"
  integration_uri           = var.validate
}