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


   lifecycle_rule {
     id      = "expire-1d"
     enabled = true

     tags = {
       "expireValue" = "1day"
     }

     expiration {
       days = 1
     }
   }

   lifecycle_rule {
     id      = "expire-2d"
     enabled = true

     tags ={
       "expireValue" = "2day"
     }

     expiration {
       days = 2
     }
   }

   lifecycle_rule {
     id      = "expire-3d"
     enabled = true

     tags ={
       "expireValue" = "3day"
     }

     expiration {
       days = 3
     }
   }

   lifecycle_rule {
     id      = "expire-4d"
     enabled = true

     tags ={
       "expireValue" = "4day"
     }

     expiration {
       days = 4
     }
   }

   lifecycle_rule {
     id      = "expire-7d"
     enabled = true

     tags= {
       "expireValue" = "7day"
     }

     expiration {
       days = 7
     }
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

output "s3-bucket_id" {
  value= aws_s3_bucket.s3_bucket.id
}
