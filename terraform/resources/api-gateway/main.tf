resource "aws_apigatewayv2_api" "api_gw" {
  name          = "image-processing-api"
  protocol_type = "HTTP"
}