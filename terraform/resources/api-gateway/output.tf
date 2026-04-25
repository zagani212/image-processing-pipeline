output "invoke_url_ws" {
  value = aws_apigatewayv2_stage.dev_stage_ws.invoke_url
}
output "invoke_url" {
  value = aws_apigatewayv2_stage.dev_stage.invoke_url
}

output "api_gw_arn" {
  value = aws_apigatewayv2_api.api_gw.execution_arn
}
output "api_gw_ws_arn" {
  value = aws_apigatewayv2_api.api_gw_ws.execution_arn
}