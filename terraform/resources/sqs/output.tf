output "metadata_queue_url" {
  value = aws_sqs_queue.metadata_queue.url
}

output "metadata_sqs_arn" {
  value = aws_sqs_queue.metadata_queue.arn
}
#####
output "thumbnail_queue_url" {
  value = aws_sqs_queue.thumbnail_queue.url
}

output "thumbnail_sqs_arn" {
  value = aws_sqs_queue.thumbnail_queue.arn
}

output "thumbnail_sqs_url" {
  value = aws_sqs_queue.thumbnail_queue.url
}
####
output "medium_queue_url" {
  value = aws_sqs_queue.medium_queue.url
}

output "medium_sqs_arn" {
  value = aws_sqs_queue.medium_queue.arn
}

output "medium_sqs_url" {
  value = aws_sqs_queue.medium_queue.url
}