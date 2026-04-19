resource "aws_apigatewayv2_api" "api_gw" {
  name          = "image-processing-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id = aws_apigatewayv2_api.api_gw.id
  auto_deploy = true
  name   = "dev-stage"
}