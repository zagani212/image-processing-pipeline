output "validate" {
  value = aws_lambda_function.validate_function.invoke_arn
}

output "connect" {
  value = aws_lambda_function.connect_handler_function.invoke_arn
}

output "getConnectionId" {
  value = aws_lambda_function.get_connection_infos_function.invoke_arn
}

output "metadata" {
  value = aws_lambda_function.metadata_function.arn
}

output "thumbnail" {
  value = aws_lambda_function.thumbnail_resize_function.arn
}

output "medium" {
  value = aws_lambda_function.medium_resize_function.arn
}

output "watermark" {
  value = aws_lambda_function.watermark_function.arn
}