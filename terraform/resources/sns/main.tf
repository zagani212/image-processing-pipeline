resource "aws_sns_topic" "resize_sns" {
  name = "images-to-be-resized"
}

resource "aws_sns_topic_subscription" "sns_thumbnail_sqs_taget" {
  topic_arn = aws_sns_topic.resize_sns.arn
  protocol  = "sqs"
  endpoint  = var.thumbnail_sqs_arn
}
resource "aws_sns_topic_subscription" "sns_meduim_sqs_taget" {
  topic_arn = aws_sns_topic.resize_sns.arn
  protocol  = "sqs"
  endpoint  = var.medium_sqs_arn
}
resource "aws_sns_topic_subscription" "sns_watermark_sqs_taget" {
  topic_arn = aws_sns_topic.resize_sns.arn
  protocol  = "sqs"
  endpoint  = var.watermark_sqs_arn
}