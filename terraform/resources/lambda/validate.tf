data "aws_iam_policy_document" "validate_function_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "validate_function_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.validate_function_assume_role.json
}



# Package the Lambda function code
data "archive_file" "validate_function_archive_file" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/validate.mjs"
  output_path = "${path.module}/../../../zip/validate.zip"
}

# Lambda function
resource "aws_lambda_function" "validate_function" {
  filename      = data.archive_file.validate_function_archive_file.output_path
  function_name = "validate"
  role          = aws_iam_role.validate_function_role.arn
  handler       = "validate.handler"
  code_sha256   = data.archive_file.validate_function_archive_file.output_base64sha256

  runtime = "nodejs24.x"
}