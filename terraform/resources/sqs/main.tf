resource "aws_sqs_queue" "metadata_queue" {
  name                      = "images-metadata-queue"
  delay_seconds             = 0
}

resource "aws_sqs_queue" "thumbnail_queue" {
  name                      = "images-thumbnail-queue"
  delay_seconds             = 0
}

resource "aws_sqs_queue" "medium_queue" {
  name                      = "images-medium-queue"
  delay_seconds             = 0
}