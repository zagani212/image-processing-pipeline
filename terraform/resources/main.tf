terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-775698064297-eu-west-3"
    key = "chat-app/terraform.tfstate"
    region = "eu-west-3"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }
}

module "s3" {
  source = "./s3"

  region = var.region
  account_id = var.account_id
}

module "dynamodb" {
  source = "./dynamodb"
}

module "sqs" {
  source = "./sqs"
}

module "sns" {
  source = "./sns"

  thumbnail_sqs_arn = module.sqs.thumbnail_sqs_arn
  medium_sqs_arn = module.sqs.medium_sqs_arn
}

module "lambda" {
  source = "./lambda"

  metadata_queue_url = module.sqs.metadata_queue_url
  images_bucket = module.s3.bucket_name
  dynamo_table = module.dynamodb.images_table
  sns_arn = module.sns.sns_arn
}

module "api_gw" {
  source = "./api-gateway"

  validate = module.lambda.validate
}

module "permission" {
  source = "./permissions"

  validate_function = "validate"
  metadata_function_arn = module.lambda.metadata
  # medium_function_arn = module.lambda.medium
  thumbnail_function_arn = module.lambda.thumbnail
  api_gw = module.api_gw.api_gw_arn
  sns_arn = module.sns.sns_arn
  bucket_arn = module.s3.bucket_arn
  dynamo_table_arn = module.dynamodb.images_table_arn
  metadata_sqs_arn = module.sqs.metadata_sqs_arn
  thumbnail_sqs_arn = module.sqs.thumbnail_sqs_arn
  thumbnail_sqs_url = module.sqs.thumbnail_sqs_url
  medium_sqs_arn = module.sqs.medium_sqs_arn
  medium_sqs_url = module.sqs.medium_sqs_url
  validate_role_name = "validate_function_role"
  thumbnail_role_name = "thumbnail_resize_function_role"
  medium_role_name = "medium_resize_function_role"
  metadata_role_name = "metadata_function_role"
}