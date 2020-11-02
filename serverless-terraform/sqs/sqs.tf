resource "aws_sqs_queue" "sqs_queue" {
  name                      = "addTagS3_dlq"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10


}

output "sqs_queue_arn"{
  value = aws_sqs_queue.sqs_queue.arn
}
