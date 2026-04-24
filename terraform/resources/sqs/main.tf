resource "aws_sqs_queue" "metadata_queue" {
  name                      = "images-metadata-queue"
  delay_seconds             = 0
}