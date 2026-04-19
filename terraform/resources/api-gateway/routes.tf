resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.api_gw.id
  route_key = "POST /images/upload"

  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}