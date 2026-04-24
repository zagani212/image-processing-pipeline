output "validate" {
  value = aws_lambda_function.validate_function.invoke_arn
}

output "metadata" {
  value = aws_lambda_function.metadata_function.arn
}