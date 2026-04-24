output "bucket_name" {
  value = format("image-processing-pipeline-bucket-%s-%s", var.account_id, var.region)
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}