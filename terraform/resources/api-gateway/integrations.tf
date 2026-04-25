resource "aws_apigatewayv2_integration" "validate" {
  api_id           = aws_apigatewayv2_api.api_gw.id
  integration_type = "AWS_PROXY"

  payload_format_version = "2.0"
  description               = "validate image"
  integration_method        = "POST"
  integration_uri           = var.validate
}

resource "aws_apigatewayv2_integration" "connect" {
  api_id           = aws_apigatewayv2_api.api_gw_ws.id
  integration_type = "AWS_PROXY"

  description               = "handle connection"
  integration_method        = "POST"
  integration_uri           = var.connect
}

resource "aws_apigatewayv2_integration" "getConnectionId" {
  api_id           = aws_apigatewayv2_api.api_gw_ws.id
  integration_type = "AWS_PROXY"

  description               = "handle retreiveConnectionInfos"
  integration_method        = "POST"
  integration_uri           = var.getConnectionId
}