resource "aws_s3_bucket" "bucket" {
  bucket = format("image-processing-pipeline-bucket-%s-%s", var.account_id, var.region)

  tags = {
    Name        = "Image Processing Pipeline Bucket"
  }
}