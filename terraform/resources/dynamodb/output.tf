output "images_table" {
  value = "Image"
}

output "images_table_arn" {
  value = aws_dynamodb_table.image_table.arn
}