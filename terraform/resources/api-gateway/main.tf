resource "aws_apigatewayv2_api" "api_gw_ws" {
  name          = "image-processing-api-ws"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_api" "api_gw" {
  name          = "image-processing"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_headers = ["authorization", "connectionId", "*"]
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
resource "aws_apigatewayv2_stage" "dev_stage_ws" {
  api_id = aws_apigatewayv2_api.api_gw_ws.id
  auto_deploy = true
  name   = "dev-stage"
}