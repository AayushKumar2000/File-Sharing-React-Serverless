variable "bucket_name" {
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  acl    = "public-read-write"
  force_destroy = true

  cors_rule {
     allowed_headers = ["*"]
     allowed_methods = ["PUT", "POST", "GET"]
     allowed_origins = ["*"]
     expose_headers  = ["ETag"]
     max_age_seconds = 3000
   }
}


resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "Stmt1599407879922",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    }
  ]
}
POLICY
}

output "s3-bucket_arn" {
  value= aws_s3_bucket.s3_bucket.arn
}
