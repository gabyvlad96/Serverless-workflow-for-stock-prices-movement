{
    "Version": "2012-10-17",
    "Id": "sqspolicy",
    "Statement": [
      {
        "Sid": "AWSEvents_Lambda_Trigger",
        "Effect": "Allow",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Action": "sqs:SendMessage",
        "Resource": "${sqsQueueArn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "${cloudWatchArn}"
          }
        }
      }
    ]
  }