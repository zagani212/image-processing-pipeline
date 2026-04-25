output "validate" {
  value = aws_lambda_function.validate_function.invoke_arn
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