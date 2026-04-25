resource "aws_apigatewayv2_route" "validate" {
  api_id    = aws_apigatewayv2_api.api_gw.id
  route_key = "POST /images/upload"

  target = "integrations/${aws_apigatewayv2_integration.validate.id}"
}

resource "aws_apigatewayv2_route" "connect" {
  api_id    = aws_apigatewayv2_api.api_gw_ws.id
  route_key = "$connect"

  target = "integrations/${aws_apigatewayv2_integration.connect.id}"
}

resource "aws_apigatewayv2_route" "getConnectionId" {
  api_id    = aws_apigatewayv2_api.api_gw_ws.id
  route_key = "getConnectionId"

  target = "integrations/${aws_apigatewayv2_integration.getConnectionId.id}"
}