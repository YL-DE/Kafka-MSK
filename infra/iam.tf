resource "aws_iam_role" "kafka-connect-role" {
  name = "kafka-connect-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "kafkaconnect.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }   
  ]
}
EOF

  tags = {
  }
}
