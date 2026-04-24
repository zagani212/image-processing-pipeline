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
  name               = "validate_function_role"
  assume_role_policy = data.aws_iam_policy_document.validate_function_assume_role.json
}

resource "aws_iam_role_policy_attachment" "validate_function_basic_policy" {
  role       = aws_iam_role.validate_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Package the Lambda function code
data "archive_file" "validate_function_archive_file" {
  type        = "zip"
  source_dir = "${path.module}/../../../lambda/validate"
  output_path = "${path.module}/../../../zip/validate.zip"
}

# Lambda function
resource "aws_lambda_function" "validate_function" {
  filename      = data.archive_file.validate_function_archive_file.output_path
  function_name = "validate"
  role          = aws_iam_role.validate_function_role.arn
  handler       = "index.handler"
  code_sha256   = data.archive_file.validate_function_archive_file.output_base64sha256
  runtime = "nodejs24.x"

  environment {
    variables = {
      SQS_QUEUE_URL = var.metadata_queue_url
      S3_BUCKET = var.images_bucket
    }
  }

}