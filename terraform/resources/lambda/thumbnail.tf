data "aws_iam_policy_document" "thumbnail_resize_function_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "thumbnail_resize_function_role" {
  name               = "thumbnail_resize_function_role"
  assume_role_policy = data.aws_iam_policy_document.thumbnail_resize_function_assume_role.json
}

resource "aws_iam_role_policy_attachment" "thumbnail_resize_function_basic_policy" {
  role       = aws_iam_role.thumbnail_resize_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Package the Lambda function code
data "archive_file" "thumbnail_resize_function_archive_file" {
  type        = "zip"
  source_dir = "${path.module}/../../../lambda/thumbnail"
  output_path = "${path.module}/../../../zip/thumbnail.zip"
}

# Lambda function
resource "aws_lambda_function" "thumbnail_resize_function" {
  filename      = data.archive_file.thumbnail_resize_function_archive_file.output_path
  function_name = "thumbnail_resize"
  role          = aws_iam_role.thumbnail_resize_function_role.arn
  handler       = "index.handler"
  code_sha256   = data.archive_file.thumbnail_resize_function_archive_file.output_base64sha256
  runtime = "nodejs24.x"

  environment {
    variables = {
      DYNAMO_TABLE = var.dynamo_table
      SNS_TOPIC_ARN = var.sns_arn
    }
  }

}