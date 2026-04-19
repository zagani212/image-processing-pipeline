resource "aws_dynamodb_table" "image_table" {
  name           = "Image"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "imageId"

  attribute {
    name = "imageId"
    type = "S"
  }

  tags = {
    Name        = "Image table"
  }
}