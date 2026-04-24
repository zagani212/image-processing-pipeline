resource "aws_apigatewayv2_api" "api_gw" {
  name          = "image-processing-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_headers = ["authorization", "*"]
    allow_methods = ["*"]
    allow_origins = ["http://localhost:5173"]
    expose_headers = ["date", "x-api-id", "*"]
    max_age = "0"
  }
}

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id = aws_apigatewayv2_api.api_gw.id
  auto_deploy = true
  name   = "dev-stage"
}