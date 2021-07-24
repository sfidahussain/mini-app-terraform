# Creates a S3 Bucket where end users can upload files.
# Once a json file is uploaded to this bucket, it has an event trigger
# which triggers a lambda function. The lambda function parses through
# the file and stores its records in the DynamoDB table 'Rates'
#  
#  There is also a lifecycle rule applied to this bucket that will move 
#  files to archival after a certain amount of days.

resource "aws_s3_bucket" "bucket" {
  bucket = "rate-upload-1"
  acl    = "public-read-write"

  force_destroy = true

  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func_upload.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_bucket_upload]
}