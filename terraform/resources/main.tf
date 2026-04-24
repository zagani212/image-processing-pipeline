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

module "lambda" {
  source = "./lambda"
}

module "api_gw" {
  source = "./api-gateway"

  validate = module.lambda.validate
}

module "permission" {
  source = "./permissions"

  validate_function = "validate"
  api_gw = module.api_gw.api_gw_arn
}