variable "bucket-name" {
  default = "s3-bucket"
  type = string
}

variable "index-document" {
  default = "index.html"
  type = string
}

variable "file-path" {
 default = null
 type = string
}

variable "upload-files" {
  default = false
  type = bool
}

resource "aws_s3_bucket" "webhosting" {
  bucket = var.bucket-name
  acl    = "public-read"

  website {
    index_document = var.index-document
    error_document = var.index-document

    routing_rules = <<-EOT
    [{
        "Condition": {
         "KeyPrefixEquals": "/*"
     },
  "Redirect": {
     "ReplaceKeyPrefixWith": "index.html"
   }
   }]
  EOT
  }
}

resource "null_resource" "upload_to_s3" {
   count = var.upload-files ? 1 : 0

  provisioner "local-exec" {
    command = "aws s3 cp ${var.file-path} s3://${aws_s3_bucket.webhosting.id} --recursive"
  }
  triggers = {
   build_number = "${timestamp()}"
}
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.webhosting.id

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
      "Resource": "arn:aws:s3:::${var.bucket-name}/*"
    }
  ]
}
POLICY
}

output "website-endpoint" {
  value = aws_s3_bucket.webhosting.website_endpoint
}
