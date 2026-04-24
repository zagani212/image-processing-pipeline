output "metadata_queue_url" {
  value = aws_sqs_queue.metadata_queue.url
}

output "metadata_sqs_arn" {
  value = aws_sqs_queue.metadata_queue.arn
}