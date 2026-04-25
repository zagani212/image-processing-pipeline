data "aws_iam_policy_document" "connect_handler_function_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "connect_handler_function_role" {
  name               = "connect_handler_function_role"
  assume_role_policy = data.aws_iam_policy_document.connect_handler_function_assume_role.json
}

resource "aws_iam_role_policy_attachment" "connect_handler_function_basic_policy" {
  role       = aws_iam_role.connect_handler_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Package the Lambda function code
data "archive_file" "connect_handler_function_archive_file" {
  type        = "zip"
  source_dir = "${path.module}/../../../lambda/connectionHandler"
  output_path = "${path.module}/../../../zip/connectionHandler.zip"
}

# Lambda function
resource "aws_lambda_function" "connect_handler_function" {
  filename      = data.archive_file.connect_handler_function_archive_file.output_path
  function_name = "connectionHandler"
  role          = aws_iam_role.connect_handler_function_role.arn
  handler       = "index.handler"
  code_sha256   = data.archive_file.connect_handler_function_archive_file.output_base64sha256
  runtime = "nodejs24.x"

}